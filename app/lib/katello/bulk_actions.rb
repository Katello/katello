module Katello
  class BulkActions
    attr_accessor :systems

    def initialize(systems)
      self.systems = systems
    end

    def install_packages(packages)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.install_package(packages)
      end
    end

    def uninstall_packages(packages)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.uninstall_package(packages)
      end
    end

    def update_packages(packages = nil)
      # if no packages are provided, a full system update will be performed (e.g ''yum update' equivalent)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.update_package(packages)
      end
    end

    def install_package_groups(groups)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.install_package_group(groups)
      end
    end

    def update_package_groups(groups)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.install_package_group(groups)
      end
    end

    def uninstall_package_groups(groups)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_bulk_action do |consumer_group|
        consumer_group.uninstall_package_group(groups)
      end
    end

    private

    def perform_bulk_action
      consumer_ids = self.systems.collect { |i| i.uuid }
      group = Glue::Pulp::ConsumerGroup.new
      group.pulp_id = SecureRandom.uuid
      group.consumer_ids = consumer_ids
      group.set_pulp_consumer_group
      yield(group)
    ensure
      group.del_pulp_consumer_group
    end
  end
end
