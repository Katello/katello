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
      before_destroy :destroy_products_orchestration
    end
  end

  module InstanceMethods

    def import_manifest zip_file_path, options = {}
      options.assert_valid_keys(:force)
      Rails.logger.info "Importing manifest for provider #{name}"
      queue_import_manifest zip_file_path, options
      self.save!
    end

    def sync
      Rails.logger.info "Syncing provider #{name}"
      self.products.collect do |p|
        p.sync
      end.flatten
    end

    def synced?
      self.products.any? { |p| p.synced? }
    end

    #get last sync status of all repositories in this provider
    def latest_sync_statuses
      self.products.collect do |p|
        p.latest_sync_statuses()
      end.flatten
    end

    # Get the most relavant status for all the repos in this Provider
    def sync_status
      statuses = self.products.reject{|r| r.empty?}.map{|r| r.sync_status()}
      return ::PulpSyncStatus.new(:state => ::PulpSyncStatus::Status::NOT_SYNCED) if statuses.empty?

      #if any of repos sync still running -> provider sync running
      idx = statuses.index do |r| r.state.to_s == ::PulpSyncStatus::Status::RUNNING.to_s end
      return statuses[idx] if idx != nil

      #else if any of repos not synced -> provider not synced
      idx = statuses.index do |r| r.state.to_s == ::PulpSyncStatus::Status::NOT_SYNCED.to_s end
      return statuses[idx] if idx != nil

      #else if any of repos sync cancelled -> provider sync cancelled
      idx = statuses.index do |r| r.state.to_s == ::PulpSyncStatus::Status::CANCELED.to_s end
      return statuses[idx] if idx != nil

      #else if any of repos sync finished with error -> provider sync finished with error
      idx = statuses.index do |r| r.state.to_s == ::PulpSyncStatus::Status::ERROR.to_s end
      return statuses[idx] if idx != nil

      #else -> all finished
      return statuses[0]
    end

    def sync_state
      self.sync_status().state
    end

    def sync_start
      start_times = Array.new
      for p in self.products
        start = p.sync_start
        start_times << start unless start.nil?
      end
      start_times.sort!
      start_times.last
    end

    def sync_finish
      finish_times = Array.new
      for r in self.products
        finish = r.sync_finish
        finish_times << finish unless finish.nil?
      end
      finish_times.sort!
      finish_times.last
    end

    def sync_size
      size = self.products.inject(0) { |sum,v| sum + v.sync_status.progress.total_size }
    end

    def last_sync
      sync_times = Array.new
      for p in self.products
        sync = p.last_sync
        sync_times << sync unless sync.nil?
      end
      sync_times.sort!
      sync_times.last
    end

    def cancel_sync
      Rails.logger.info "Cancelling synchronization of provider #{name}"
      self.products.each do |p|
        p.cancel_sync
      end
    end

    def add_custom_product(name, description, url, gpg = nil)
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
        product.gpg_key = gpg
        product.save!
        product
      rescue => e
        Rails.logger.error "Failed to create custom product #{name} for provider #{self.name}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end
    end

    def url_to_host_and_path(url = "")
      parsed = URI.parse(url)
      ["#{parsed.scheme}://#{parsed.host}#{ parsed.port ? ':' + parsed.port.to_s : '' }", parsed.path]
    end

    def del_products
      Rails.logger.info "Deleting all products for provider: #{name}"
      self.products.each do |p|
        p.destroy
      end
      true
    rescue => e
      Rails.logger.error "Failed to delete all products for provider #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def owner_import zip_file_path, options
      Candlepin::Owner.import self.organization.cp_key, zip_file_path, options
    end

    def owner_imports
      Candlepin::Owner.imports self.organization.cp_key
    end

    def queue_import_manifest zip_file_path, options
      queue.create(:name => "import manifest #{zip_file_path} for owner: #{self.organization.name}", :priority => 3, :action => [self, :owner_import, zip_file_path, options])
      queue.create(:name => "import of products in manifest #{zip_file_path}",                       :priority => 5, :action => [self, :import_products_from_cp])
    end

    def import_products_from_cp
      added_products.each do |product_attrs|
        product = Glue::Candlepin::Product.import_from_cp(product_attrs) do |p|
          p.provider = self
          p.environments << self.organization.locker
        end
      end
    end

    def destroy_products_orchestration
      queue.create(:name => "delete products for provider: #{self.name}", :priority => 1, :action => [self, :del_products])
    end


    protected

    def added_products
      product_existing_in_katello_ids = self.organization.locker.products.all(:select => "cp_id").map(&:cp_id)
      product_existing_in_cp_ids = get_pool_product_ids

      new_product_ids = (product_existing_in_cp_ids - product_existing_in_katello_ids)
      new_product_ids.collect {|id| (Candlepin::Product.get(id))[0] }
    end

    def get_pool_product_ids
      pools = Candlepin::Owner.pools self.organization.cp_key
      pools.collect do |pool|
        provided_products = pool[:providedProducts]
        pool_product_ids = []
        pool_product_ids = provided_products.collect {|provided| provided[:productId]} unless provided_products.nil?
        # Done with provided products, lets add the *actual* product
        pool_product_ids << pool[:productId]
      end.flatten.uniq
    end

    def get_all_product_ids
      Candlepin::Product.all.map{ |p| p['id'] }
    end

    def get_assigned_content_ids
      ids = Candlepin::Product.all.collect{ |p| p['productContent'] }.flatten(1).collect{ |content| content['content']['id'] }
      ids
    end

    def get_all_content_ids
      ids = Candlepin::Content.all.map{ |c| c['id'] }
      ids
    end
  end


end
