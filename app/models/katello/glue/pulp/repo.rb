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

        def self.delete_orphaned_content
          Katello.pulp_server.resources.content.remove_orphans
        end

        def self.needs_importer_updates(repos, smart_proxy)
          repos.select do |repo|
            repo_details = repo.backend_service(smart_proxy).backend_data
            next unless repo_details
            capsule_importer = repo_details["importers"][0]
            !repo.importer_matches?(capsule_importer, smart_proxy)
          end
        end

        def self.needs_distributor_updates(repos, smart_proxy)
          repos.select do |repo|
            repo_details = repo.backend_service(smart_proxy).backend_data
            next unless repo_details
            !repo.distributors_match?(repo_details["distributors"], smart_proxy)
          end
        end
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

      def pulp_counts_differ?
        pulp_counts = pulp_repo_facts[:content_unit_counts]
        rpms.count != pulp_counts['rpm'].to_i ||
          srpms.count != pulp_counts['srpm'].to_i ||
          errata.count != pulp_counts['erratum'].to_i ||
          package_groups.count != pulp_counts['package_group'].to_i ||
          docker_manifests.count != pulp_counts['docker_manifest'].to_i ||
          docker_tags.count != pulp_counts['docker_tag'].to_i
      end

      def empty_in_pulp?
        pulp_repo_facts[:content_unit_counts].values.all? { |value| value == 0 }
      end

      def generate_importer(capsule = ::SmartProxy.default_capsule!)
        backend_service(capsule).generate_importer
      end

      def generate_distributors(capsule = ::SmartProxy.default_capsule!)
        backend_service(capsule).generate_distributors
      end

      def package_group_count
        content_unit_counts = 0
        if self.pulp_repo_facts
          content_unit_counts = self.pulp_repo_facts[:content_unit_counts][:package_group]
        end
        content_unit_counts
      end

      def clone_file_metadata(to_repo)
        Katello.pulp_server.extensions.yum_repo_metadata_file.copy(self.pulp_id, to_repo.pulp_id)
      end

      def unassociate_by_filter(content_type, filter_clauses)
        criteria = {:type_ids => [content_type], :filters => {:unit => filter_clauses}}
        case content_type
        when Katello.pulp_server.extensions.rpm.content_type
          criteria[:fields] = { :unit => Pulp::Rpm::PULP_SELECT_FIELDS}
        when Katello.pulp_server.extensions.errata.content_type
          criteria[:fields] = { :unit => Pulp::Erratum::PULP_SELECT_FIELDS}
        end
        Katello.pulp_server.extensions.repository.unassociate_units(self.pulp_id, criteria)
      end

      def clear_contents
        tasks = content_types.flat_map { |type| type.unassociate_from_repo(self.pulp_id, {}) }

        tasks << Katello.pulp_server.extensions.repository.unassociate_units(self.pulp_id,
                   :type_ids => ['rpm'], :filters => {}, :fields => { :unit => Pulp::Rpm::PULP_SELECT_FIELDS})
        tasks
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

      def find_distributor(use_clone_distributor = false)
        dist_type_id = if use_clone_distributor
                         case self.content_type
                         when Repository::YUM_TYPE
                           Runcible::Models::YumCloneDistributor.type_id
                         when Repository::PUPPET_TYPE
                           Runcible::Models::PuppetInstallDistributor.type_id
                         end
                       else
                         case self.content_type
                         when Repository::YUM_TYPE
                           Runcible::Models::YumDistributor.type_id
                         when Repository::PUPPET_TYPE
                           Runcible::Models::PuppetInstallDistributor.type_id
                         end
                       end

        distributors.detect { |dist| dist["distributor_type_id"] == dist_type_id }
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

      def unit_type_id
        case content_type
        when Repository::YUM_TYPE
          "rpm"
        when Repository::DOCKER_TYPE
          "docker_manifest"
        when Repository::OSTREE_TYPE
          "ostree"
        when Repository::FILE_TYPE
          "iso"
        when Repository::DEB_TYPE
          "deb"
        when Repository::ANSIBLE_COLLECTION_TYPE
          "ansible_collection"
        end
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

      def published?
        distributors.map { |dist| dist['last_publish'] }.compact.any?
      end

      def capsule_download_policy(capsule)
        policy = capsule.download_policy || Setting[:default_proxy_download_policy]
        if self.yum?
          if policy == ::SmartProxy::DOWNLOAD_INHERIT
            self.root.download_policy
          else
            policy
          end
        end
      end

      def distributors_match?(capsule_distributors, capsule)
        generated_distributor_configs = self.generate_distributors(capsule)
        generated_distributor_configs.all? do |gen_dist|
          type = gen_dist.class.type_id
          found_on_capsule = capsule_distributors.find { |dist| dist['distributor_type_id'] == type }
          found_on_capsule && filtered_distribution_config_equal?(gen_dist.config, found_on_capsule['config'])
        end
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

      def filtered_distribution_config_equal?(generated_config, actual_config)
        generated = generated_config.clone
        actual = actual_config.clone
        #We store 'default' checksum type as nil, but pulp will default to sha256, so if we haven't set it, ignore it
        if generated.keys.include?('checksum_type') && generated['checksum_type'].nil?
          generated.delete('checksum_type')
          actual.delete('checksum_type')
        end
        generated.compact == actual.compact
      end

      def importer_matches?(capsule_importer, capsule)
        generated_importer = self.generate_importer(capsule)
        capsule_importer.try(:[], 'importer_type_id') == generated_importer.id &&
            generated_importer.config.compact == capsule_importer['config'].compact
      end

      protected

      def object_to_hash(object)
        hash = {}
        object.instance_variables.each { |var| hash[var.to_s.delete("@")] = object.instance_variable_get(var) }
        hash
      end

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
