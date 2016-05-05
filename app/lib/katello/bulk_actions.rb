module Katello
  class BulkActions
    attr_accessor :consumer_ids

    def initialize(hosts)
      @consumer_ids = hosts.map { |host| host.content_facet.try(:uuid) }.compact
    end

    def install_packages(packages, _options = {})
      fail Errors::EmptyBulkActionException if self.consumer_ids.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.install_package(packages)
      end
    end

    def uninstall_packages(packages, _options = {})
      fail Errors::EmptyBulkActionException if self.consumer_ids.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.uninstall_package(packages)
      end
    end

    def update_packages(packages = nil, options = {})
      fail Errors::EmptyBulkActionException if self.consumer_ids.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.update_package(packages, options)
      end
    end

    def install_package_groups(groups, _options = {})
      fail Errors::EmptyBulkActionException if self.consumer_ids.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.install_package_group(groups)
      end
    end

    def update_package_groups(groups, _options = {})
      fail Errors::EmptyBulkActionException if self.consumer_ids.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.install_package_group(groups)
      end
    end

    def uninstall_package_groups(groups, _options = {})
      fail Errors::EmptyBulkActionException if self.consumer_ids.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.uninstall_package_group(groups)
      end
    end

    private

    def perform_bulk_action
      group = Katello::Pulp::ConsumerGroup.new
      group.pulp_id = SecureRandom.uuid
      group.consumer_ids = consumer_ids
      group.set_pulp_consumer_group
      yield(group)
    ensure
      group.del_pulp_consumer_group
    end
  end
end
