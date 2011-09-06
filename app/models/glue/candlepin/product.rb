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

  module InstanceMethods

    def initialize(attrs = nil)
      unless attrs.nil?
        attributes_key = attrs.has_key?(:attributes) ? :attributes : 'attributes'
        if attrs.has_key?(attributes_key)
          attrs[:attrs] = attrs[attributes_key]
          attrs.delete(attributes_key)
        end

        @productContent = [] unless attrs.has_key?(:productContent)

        # ugh. hack-ish. otherwise we have to modify code every time things change on cp side
        attrs = attrs.reject do |k, v|
          !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
      end

      super(attrs)
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
      ar_safe_json.except('id')
    end

    def set_product
      Rails.logger.info "Creating a product in candlepin: #{name}"
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
      Rails.logger.info "Deleting product in candlepin: #{name}"
      Candlepin::Product.destroy self.cp_id
    rescue => e
      Rails.logger.error "Failed to delete candlepin product #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def set_content
      self.productContent.each do |pc|
        Rails.logger.info "Creating content in candlepin: #{pc.content.name}"
        #TODO: use json returned from cp to populate productContent
        new_content = Candlepin::Content.create pc.content
        pc.content.id = new_content[:id]
      end
    rescue => e
      Rails.logger.error "Failed to create content for product in candlepin #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def add_new_content(name, path, repo_type)
      check_for_repo_conflicts(name)
      # create new content
      pc = Glue::Candlepin::ProductContent.new({:content => {
          :name => name,
          :contentUrl => path,
          :gpgUrl => "",
          :type => repo_type,
          :label => "#{self.cp_id}_#{name}",
          :vendor => "Custom"
        }
      })

      self.productContent_will_change!
      self.productContent << pc
      save!
      pc
    end

    def add_content
      self.productContent.each do |pc|
        Rails.logger.info "Adding content to product '#{self.cp_id}' in candlepin: #{pc.content.name}"
        Candlepin::Product.add_content cp_id, pc.content.id, pc.enabled
      end
    rescue => e
      Rails.logger.error "Failed to create content for product in candlepin #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_content
      return true unless productContent_changed?

      # can't use content id, as it will be nil for new content, content label is unique however, will use that
      old_content = productContent_change[0].nil? ? [] : productContent_change[0].map {|pc| pc.content.label}
      new_content = productContent_change[1].map {|pc| pc.content.label}

      added_content   = new_content - old_content
      deleted_content = old_content - new_content

      self.productContent.select {|pc| deleted_content.include?(pc.content.label)}.each do |pc|
        Rails.logger.debug "deleting content #{pc.content.id}"
        Candlepin::Content.destroy(pc.content.id)
      end

      self.productContent.select {|pc| added_content.include?(pc.content.label)}.each do |pc|
        Rails.logger.debug "creating content #{pc.content.name}"
        new_content = Candlepin::Content.create pc.content
        pc.content.id = new_content[:id] # candlepin generates id for new content

        Rails.logger.debug "adding content #{pc.content.id}"
        Candlepin::Product.add_content cp_id, pc.content.id, pc.enabled
      end
    end

    def create_unlimited_subscription
      Rails.logger.info "Creating unlimited subscription for product #{name} in candlepin"
      Candlepin::Product.create_unlimited_subscription self.organization.cp_key, self.cp_id
    rescue => e
      Rails.logger.error "Failed to create unlimited subscription for product in candlepin #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def delete_subscriptions
      Rails.logger.info "Deleting subscriptions for product #{name} in candlepin"
      Candlepin::Product.delete_subscriptions self.organization.cp_key, self.cp_id
    rescue => e
      Rails.logger.error "Failed to delete unlimited subscription for product in candlepin #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def save_product_orchestration
      case self.orchestration_for
        when :create
          queue.create(:name => "candlepin product: #{self.name}", :priority => 3, :action => [self, :set_product])
          queue.create(:name => "candlepin content: #{self.name}", :priority => 4, :action => [self, :set_content])
          queue.create(:name => "add content to product in candlepin: #{self.name}", :priority => 5, :action => [self, :add_content])
          # we create unlimited subscriptions for generic yum providers
          if self.provider and self.provider.yum_repo?
            queue.create(:name => "create unlimited subscription for product in candlepin: #{self.name}", :priority => 7, :action => [self, :create_unlimited_subscription])
          end
        when :promote
          queue.create(:name => "update candlepin product: #{self.name}", :priority =>3, :action => [self, :update_content])
        when :import_from_cp
          #do nothing
      end
    end

    def destroy_product_orchestration
      queue.create(:name => "delete subscriptions for product in candlepin: #{self.name}", :priority => 7, :action => [self, :delete_subscriptions])
      queue.create(:name => "candlepin product: #{self.name}", :priority => 8, :action => [self, :del_product])
    end

    protected

    def check_for_repo_conflicts(repo_name)
      unless self.repos(self.locker, {:name => repo_name}).empty?
        raise Errors::ConflictException.new(_("There is already a repo with the name [ %s ] for product [ %s ]") % [repo_name, self.name])
      end
    end

  end
end
