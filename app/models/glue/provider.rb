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

require_dependency 'resources/candlepin'

module Glue::Provider

  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      before_save :save_products_orchestration
      before_destroy :destroy_products_orchestration
    end
  end

  module InstanceMethods

    def import_manifest zip_file_path
      Rails.logger.info "Importing manifest for provider #{name}"
      queue_import_manifest zip_file_path
      process queue
    end

    def sync
      Rails.logger.info "Syncing provider #{name}"
      self.products.each do |p|
        Rails.logger.info "Syncing product #{p.name}"
        p.sync
      end
    end

    def cancel_sync
      Rails.logger.info "Cancelling synchronization of provider #{name}"
      self.products.each do |p|
        Rails.logger.info "Cancelling synchronization of  product #{p.name}"
        p.cancel_sync
      end
    end

    def add_custom_product(name, description, url)
      # URL isn't used yet until we can do custom repo discovery in pulp
      begin
        Rails.logger.info "Creating custom product #{name} for provider: #{self.name}"
        product = Product.new({
            :name => name,
            :description => description,
            :multiplier => 1
        })
        self.products << product
        product.provider = self
        product.environments << self.organization.locker
        product.save!
        product
      rescue => e
        Rails.logger.error "Failed to create custom product #{name} for provider #{self.name}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end
    end

    def update_products
      Rails.logger.info "Updating products for provider: #{name}"
      self.products.each do |p|
        p.provider = self
        p.update_attributes!({
            :productContent => [Glue::Candlepin::ProductContent.new(:content => {:id => p.name})] # FIX ME: don't think this is correct
        })
        #update name only for custom products
        if p.name == old.name
          p.update_attributes!({:name => name})
        end
      end
    rescue => e
      Rails.logger.error "Failed to update products for provider #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def url_to_host_and_path(url = "")
      parsed = URI.parse(url)
      ["#{parsed.scheme}://#{parsed.host}#{ parsed.port ? ':' + parsed.port.to_s : '' }", parsed.path]
    end

    def del_products
      Rails.logger.info "Deleting all products #{name} for provider: #{name}"
      self.products.each do |p|
        p.destroy
      end
    rescue => e
      Rails.logger.error "Failed to delete all products #{name} for provider #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def set_product attrs
      Rails.logger.info "Creating product #{attrs['name']} for provider: #{name}"
      productContent_attrs = attrs.delete(:productContent) if attrs.has_key?(:productContent)
      product = Product.new(attrs) do |p|
        p.provider = self
        p.environments << self.organization.locker
        p.productContent = p.build_productContent(productContent_attrs)
      end
      product.save!
    rescue => e
      Rails.logger.error "Failed to create product #{attrs['name']} for provider #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def import_product_from_cp attrs
      Rails.logger.info "Importing product #{attrs['name']} for provider: #{name}"
      productContent_attrs = attrs.delete(:productContent) if attrs.has_key?(:productContent)
      product = Product.new(attrs) do |p|
        p.provider = self
        p.environments << self.organization.locker
        p.productContent = p.build_productContent(productContent_attrs)
      end
      product.orchestration_for = :import_from_cp
      product.save!
    rescue => e
      Rails.logger.error "Failed to create product #{attrs['name']} for provider #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end


    def owner_import zip_file_path
      Candlepin::Owner.import self.organization.cp_key, zip_file_path
    end

    def queue_import_manifest zip_file_path
      queue.create(:name => "import manifest #{zip_file_path} for owner: #{self.organization.name}", :priority => 3, :action => [self, :owner_import, zip_file_path])
      queue.create(:name => "import of products in manifest #{zip_file_path}", :priority => 5, :action => [self, :queue_pool_product_creation])
    end

    def queue_import_product_from_cp attrs
      queue.create(:name => "create product imported from candlepin: #{attrs['name']}", :priority => 4, :action => [self, :import_product_from_cp, attrs])
    end

    def queue_pool_product_creation
      pools = Candlepin::Owner.pools self.organization.cp_key
      product_ids = pools.collect do |pool|
        provided_products = pool[:providedProducts]
        pool_product_ids = []
        pool_product_ids = provided_products.collect {|provided| provided[:productId]} unless provided_products.nil?
        # Done with provided products, lets add the *actual* product
        pool_product_ids << pool[:productId]
      end.flatten.uniq

      existing_product_ids = self.organization.locker.products.all(:select => "cp_id").map(&:cp_id)
      products_to_create = (product_ids - existing_product_ids).collect {|id| (Candlepin::Product.get(id))[0] }

      products_to_create.each do |p|
        Rails.logger.info "product: "+p.to_json
        queue_import_product_from_cp p
      end
      process queue
    end

    def save_products_orchestration
      case self.orchestration_for
        when :update
          queue.create(:name => "update products for provider: #{self.name}", :priority => 3, :action => [self, :update_products])
      end
    end

    def destroy_products_orchestration
      queue.create(:name => "delete custom product for provider: #{self.name}", :priority => 1, :action => [self, :del_products])
    end
  end

end
