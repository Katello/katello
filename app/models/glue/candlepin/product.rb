#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'resources/candlepin'

module Glue::Candlepin::Product

  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do
      lazy_accessor :productContent, :multiplier, :href, :attrs,
        :initializer => lambda { convert_from_cp_fields(Candlepin::Product.get(cp_id)[0]) }
      # Entitlement Certificate for this product
      lazy_accessor :certificate,
        :initializer => lambda { Candlepin::Product.certificate(cp_id) },
        :unless => lambda { cp_id.nil? }
      # Entitlement Key for this product
      lazy_accessor :key, :initializer => lambda { Candlepin::Product.key(cp_id) }, :unless => lambda { cp_id.nil? }

      before_save :save_product_orchestration
      before_destroy :destroy_product_orchestration
    end
  end

  def self.validate_name(name)
    name.gsub(/[^a-z0-9\-_ ]/i,"")
  end

  def self.import_from_cp(attrs=nil, &block)
    if attrs.has_key?(:productContent)
      productContent_attrs = attrs.delete(:productContent)
    else
      productContent_attrs = []
    end

    attrs = attrs.merge('name' => validate_name(attrs['name']))

    # orchestration has 2 phases:
    # 1) create the product and environment_product active records
    # 2) create repositories and delete content in the content library
    product = Product.new(attrs, &block)
    product.orchestration_for = :import_from_cp_ar_setup
    product.save!
    product.productContent_will_change!
    product.productContent = product.build_productContent(productContent_attrs)
    product.orchestration_for = :import_from_cp
    product.save!

  rescue => e
    Rails.logger.error "Failed to create product #{attrs['name']} for provider #{name}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

  def self.import_marketing_from_cp(attrs, engineering_product_ids, &block)
    attrs = attrs.merge('name' => validate_name(attrs['name']))

    product = MarketingProduct.new(attrs, &block)
    product.orchestration_for = :import_from_cp_ar_setup
    product.save!
    engineering_product_ids.each do |engineering_product_id|
      product.marketing_engineering_products.create(:engineering_product_id => engineering_product_id)
    end
    product
  rescue => e
    Rails.logger.error "Failed to create product #{attrs['name']} for provider #{name}: #{e}, #{e.backtrace.join("\n")}"
    raise e
  end

  module InstanceMethods

    def initialize(attribs = nil)
      unless attribs.nil?
        attributes_key = attribs.has_key?(:attributes) ? :attributes : 'attributes'
        if attribs.has_key?(attributes_key)
          attribs[:attrs] = attribs[attributes_key]
          attribs.delete(attributes_key)
        end

        @productContent = [] unless attribs.has_key?(:productContent)

        # ugh. hack-ish. otherwise we have to modify code every time things change on cp side
        attribs = attribs.reject do |k, v|
          !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
      end

      super(attribs)
    end

    def build_productContent(attrs)
      @productContent = attrs.collect { |pc| Glue::Candlepin::ProductContent.new pc }
    end

    def support_level
      return _attr(:support_level)
    end

    def arch
      attrs.each do |attr|
        if attr[:name] == 'arch'
          return "noarch" if attr[:value] == 'ALL'
          return attr[:value]
        end
      end
      default_arch
    end

    def _attr(key)
      puts "Looking for: #{key}"
      attrs.each do |attr|
        puts "attr: name: #{attr[:name]} value: #{attr[:value]}"
        if attr[:name] == key.to_s
          return attr[:value]
        end
      end
      nil
    end

    def default_arch
      "noarch"
    end

    def convert_from_cp_fields(cp_json)
      ar_safe_json = cp_json.has_key?(:attributes) ? cp_json.merge(:attrs => cp_json.delete(:attributes)) : cp_json
      ar_safe_json[:productContent] = ar_safe_json[:productContent].collect { |pc| Glue::Candlepin::ProductContent.new pc }
      ar_safe_json[:attrs] ||=[]
      ar_safe_json.except('id')
    end

    def add_content content
      Candlepin::Product.add_content self.cp_id, content.content.id, true
      self.productContent << content
    end

    def remove_content_by_id content_id
      Candlepin::Product.remove_content cp_id, content_id
    end

    def set_product
      Rails.logger.debug "Creating a product in candlepin: #{name}"
      json = Candlepin::Product.create({
        :name => self.name,
        :multiplier => self.multiplier || 1,
        :attributes => self.attrs || [] # name collision with ActiveRecord
      })
      self.cp_id = json[:id]
    rescue => e
      Rails.logger.error "Failed to create candlepin product #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_product
      Rails.logger.debug "Deleting product in candlepin: #{name}"
      Candlepin::Product.destroy self.cp_id
      true
    rescue => e
      Rails.logger.error "Failed to delete candlepin product #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end


    def set_content
      self.productContent.each do |pc|
        Rails.logger.debug "Creating content in candlepin: #{pc.content.name}"
        #TODO: use json returned from cp to populate productContent
        new_content = Candlepin::Content.create pc.content
        pc.content.id = new_content[:id]
      end
    rescue => e
      Rails.logger.error "Failed to create content for product #{name} in candlepin: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_content
      self.productContent.each do |pc|
        Rails.logger.debug "Deleting content in candlepin: #{pc.content.name}"
        Candlepin::Content.destroy(pc.content.id)
      end
    rescue => e
      Rails.logger.error "Failed to delete content for product #{name} in candlepin: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def remove_all_content
      # engineering products handle content deletion when destroying
      # repositories
      return true unless self.is_a? MarketingProduct

      self.productContent.each do |pc|
        Rails.logger.debug "Removing content from product '#{self.cp_id}' in candlepin: #{pc.content.name}"
        self.remove_content_by_id pc.content.id
      end
      true
    rescue => e
      Rails.logger.error "Failed to remove content form a product in candlepin #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end


    def update_content
      return true unless productContent_changed?

      deleted_content_ids.each do |content_id|
        Rails.logger.debug "deleting content #{content_id}"
        Candlepin::Product.remove_content cp_id, content_id
        Candlepin::Content.destroy(content_id)
      end

      added_content.each do |pc|
        Rails.logger.debug "creating content #{pc.content.name}"
        new_content = Candlepin::Content.create pc.content
        pc.content.id = new_content[:id] # candlepin generates id for new content

        Rails.logger.debug "adding content #{pc.content.id}"
        Candlepin::Product.add_content cp_id, pc.content.id, pc.enabled
      end
    end

    def set_unlimited_subscription
      # we create unlimited subscriptions only for generic yum providers
      if self.provider and self.provider.yum_repo?
        Rails.logger.debug "Creating unlimited subscription for product #{name} in candlepin"
        Candlepin::Product.create_unlimited_subscription self.organization.cp_key, self.cp_id
      end
      true
    rescue => e
      Rails.logger.error "Failed to create unlimited subscription for product in candlepin #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_unlimited_subscription
      # we create unlimited subscriptions only for generic yum providers
      if self.provider and self.provider.yum_repo?
        self.del_subscriptions
      end
    end

    def del_subscriptions
      Rails.logger.debug "Deleting subscriptions for product #{name} in candlepin"
      Candlepin::Product.delete_subscriptions self.organization.cp_key, self.cp_id
      true
    rescue => e
      Rails.logger.error "Failed to delete subscription for product in candlepin #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def save_product_orchestration
      case self.orchestration_for
        when :create
          pre_queue.create(:name => "candlepin product: #{self.name}",                          :priority => 1, :action => [self, :set_product])
          pre_queue.create(:name => "create unlimited subscription in candlepin: #{self.name}", :priority => 2, :action => [self, :set_unlimited_subscription])
        when :import_from_cp
          # we leave it as it is - to not break re-import logic
        when :update
          #called when sync schedule changed, repo added, repo deleted
          pre_queue.create(:name => "update content in candlein: #{self.name}", :priority => 1, :action => [self, :update_content])
        when :promote
          #queue.create(:name => "update candlepin product: #{self.name}", :priority =>3, :action => [self, :update_content])
      end
    end

    def destroy_product_orchestration
      pre_queue.create(:name => "delete subscriptions for product in candlepin: #{self.name}", :priority => 7,  :action => [self, :del_subscriptions])
      pre_queue.create(:name => "remove candlepin content from a product: #{self.name}",       :priority => 8,  :action => [self, :remove_all_content])
      pre_queue.create(:name => "candlepin product: #{self.name}",                             :priority => 10, :action => [self, :del_product])
    end

    protected
    def added_content
      old_content_ids = productContent_change[0].nil? ? [] : productContent_change[0].map {|pc| pc.content.label}
      new_content_ids = productContent_change[1].map {|pc| pc.content.label}

      added_content_ids = new_content_ids - old_content_ids

      added_content = productContent_change[1].select {|pc| added_content_ids.include?(pc.content.label)}
      added_content
    end

    def deleted_content
      old_content_ids = productContent_change[0].nil? ? [] : productContent_change[0].map {|pc| pc.content.label}
      new_content_ids = productContent_change[1].map {|pc| pc.content.label}

      deleted_content_ids = old_content_ids - new_content_ids

      deleted_content = productContent_change[0].select {|pc| deleted_content_ids.include?(pc.content.label)}
      deleted_content
    end

  end
end
