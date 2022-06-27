module Katello
  module Glue::Pulp::Repo
    # TODO: move into submodules
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods

      base.class_eval do
        lazy_accessor :pulp_repo_facts,
                      :initializer => (lambda do |_s|
                                         if pulp_id
                                           begin
                                             Katello.pulp_server.extensions.repository.retrieve_with_details(pulp_id)
                                           rescue RestClient::ResourceNotFound
                                             nil # not found = it was not orchestrated yet
                                           end
                                         end
                                       end)

        lazy_accessor :importers,
                      :initializer => lambda { |_s| pulp_repo_facts["importers"] if pulp_id }

        lazy_accessor :distributors,
                      :initializer => lambda { |_s| pulp_repo_facts["distributors"] if pulp_id }
      end
    end

    module InstanceMethods
      # TODO: This module is too long. See https://projects.theforeman.org/issues/12584.
      def last_sync
        last = self.latest_dynflow_sync
        last.nil? ? nil : last.to_s
      end

      def initialize(attrs = nil)
        if attrs.nil?
          super
        else
          #rename "type" to "cp_type" (activerecord and candlepin variable name conflict)
          #if attrs.has_key?(type_key) && !(attrs.has_key?(:cp_type) || attrs.has_key?('cp_type'))
          #  attrs[:cp_type] = attrs[type_key]
          #end

          attrs_used_by_model = attrs.reject do |k, _v|
            !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
          end
          super(attrs_used_by_model)
        end
      end

      def srpm_count
        pulp_repo_facts['content_unit_counts']['srpm']
      end

      def to_hash
        pulp_repo_facts.merge(as_json).merge(:sync_state => sync_state)
      end

      def pulp_scratchpad_checksum_type
        if SmartProxy.pulp_primary.has_feature?(SmartProxy::PULP_FEATURE)
          pulp_repo_facts&.dig('scratchpad', 'checksum_type')
        end
      end

      def package_group_count
        content_unit_counts = 0
        if self.pulp_repo_facts
          content_unit_counts = self.pulp_repo_facts[:content_unit_counts][:package_group]
        end
        content_unit_counts
      end

      def content_types
        [Katello.pulp_server.extensions.errata,
         Katello.pulp_server.extensions.package_group,
         Katello.pulp_server.extensions.module_stream
        ]
      end

      def sync_status
        self._get_most_recent_sync_status if @sync_status.nil?
      end

      def sync_state
        status = sync_status
        return PulpSyncStatus::Status::NOT_SYNCED if status.nil?
        status.state
      end

      def synced?
        sync_history = self.sync_status
        !sync_history.nil? && successful_sync?(sync_history)
      end

      def successful_sync?(sync_history_item)
        sync_history_item['state'] == PulpTaskStatus::Status::FINISHED.to_s
      end

      def sort_sync_status(statuses)
        statuses.sort! do |a, b|
          if a['finish_time'].nil? && b['finish_time'].nil?
            if a['start_time'].nil?
              1
            elsif b['start_time'].nil?
              -1
            else
              a['start_time'] <=> b['start_time']
            end
          elsif a['finish_time'].nil?
            if a['start_time'].nil?
              1
            else
              -1
            end
          elsif b['finish_time'].nil?
            if b['start_time'].nil?
              -1
            else
              1
            end
          else
            b['finish_time'] <=> a['finish_time']
          end
        end
        return statuses
      end

      def unit_search(options = {})
        Katello.pulp_server.extensions.repository.unit_search(self.pulp_id, options)
      end

      def docker?
        self.content_type == Repository::DOCKER_TYPE
      end

      def file?
        self.content_type == Repository::FILE_TYPE
      end

      def yum?
        self.content_type == Repository::YUM_TYPE
      end

      def ostree?
        self.content_type == Repository::OSTREE_TYPE
      end

      def deb?
        self.content_type == Repository::DEB_TYPE
      end

      def ansible_collection?
        self.content_type == Repository::ANSIBLE_COLLECTION_TYPE
      end

      def needs_metadata_publish?
        last_publish = last_publish_task.try(:[], 'finish_time')
        last_sync = last_sync_task.try(:[], 'finish_time')
        return false if last_sync.nil?
        return true if last_publish.nil?

        Time.parse(last_sync) >= Time.parse(last_publish)
      end

      def last_sync_task
        tasks = Katello.pulp_server.extensions.repository.sync_status(self.pulp_id)
        most_recent_task(tasks)
      end

      def last_publish_task
        tasks = Katello.pulp_server.extensions.repository.publish_status(self.pulp_id)
        most_recent_task(tasks, true)
      end

      def most_recent_task(tasks, only_successful = false)
        tasks = tasks.select { |t| t['finish_time'] }.sort_by { |t| t['finish_time'] }
        tasks = tasks.select { |task| task['error'].nil? } if only_successful
        tasks.last
      end

      protected

      def _get_most_recent_sync_status
        begin
          history = Katello.pulp_server.extensions.repository.sync_status(pulp_id)

          if history.blank?
            history = PulpSyncStatus.convert_history(Katello.pulp_server.extensions.repository.sync_history(pulp_id))
          end
        rescue
          history = PulpSyncStatus.convert_history(Katello.pulp_server.extensions.repository.sync_history(pulp_id))
        end

        if history.blank?
          return PulpSyncStatus.new(:state => PulpSyncStatus::Status::NOT_SYNCED)
        else
          history = sort_sync_status(history)
          return PulpSyncStatus.pulp_task(history.first.with_indifferent_access)
        end
      end
    end
  end
end
