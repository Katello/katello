module Katello
  module Pulp
    class ConsumerGroup
      attr_accessor :pulp_id, :consumer_ids

      def set_pulp_consumer_group
        Rails.logger.debug "creating pulp consumer group '#{self.pulp_id}'"
        Katello.pulp_server.extensions.consumer_group.create(self.pulp_id, :consumer_ids => (consumer_ids || []))
      rescue => e
        Rails.logger.error "Failed to create pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def del_pulp_consumer_group
        Rails.logger.debug "deleting pulp consumer group '#{self.pulp_id}'"
        Katello.pulp_server.extensions.consumer_group.delete(self.pulp_id)
      rescue => e
        Rails.logger.error "Failed to delete pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def install_package(packages)
        Rails.logger.debug "Scheduling package install for consumer group #{self.pulp_id}"

        Katello.pulp_server.extensions.consumer_group.install_content(self.pulp_id,
                                                                        'rpm',
                                                                        packages,
                                                                        'importkeys' => true)
      rescue => e
        Rails.logger.error "Failed to schedule package install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def uninstall_package(packages)
        Rails.logger.debug "Scheduling package uninstall for consumer group #{self.pulp_id}"

        Katello.pulp_server.extensions.consumer_group.uninstall_content(self.pulp_id,
                                                                          'rpm',
                                                                          packages)
      rescue => e
        Rails.logger.error "Failed to schedule package uninstall for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def update_package(packages, options = {})
        Rails.logger.debug "Scheduling package update for consumer group #{self.pulp_id}"

        options.merge!(:importkeys => true)
        options[:all] = true if options[:update_all]
        Katello.pulp_server.extensions.consumer_group.update_content(self.pulp_id,
                                                                       'rpm',
                                                                       packages,
                                                                       options)
      rescue => e
        Rails.logger.error "Failed to schedule package update for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def install_package_group(groups)
        Rails.logger.debug "Scheduling package group install for consumer group #{self.pulp_id}"

        Katello.pulp_server.extensions.consumer_group.install_content(self.pulp_id,
                                                                        'package_group',
                                                                        groups,
                                                                        'importkeys' => true)
      rescue => e
        Rails.logger.error "Failed to schedule package group install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def uninstall_package_group(groups)
        Rails.logger.debug "Scheduling package group uninstall for consumer group #{self.pulp_id}"

        Katello.pulp_server.extensions.consumer_group.uninstall_content(self.pulp_id,
                                                                          'package_group',
                                                                          groups)
      rescue => e
        Rails.logger.error "Failed to schedule package group uninstall for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def install_consumer_errata(errata_ids)
        Rails.logger.debug "Scheduling errata install for consumer group #{self.pulp_id}"

        Katello.pulp_server.extensions.consumer_group.install_content(self.pulp_id,
                                                                        'erratum',
                                                                        errata_ids,
                                                                        'importkeys' => true)
      rescue => e
        Rails.logger.error "Failed to schedule errata install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end
    end
  end
end
