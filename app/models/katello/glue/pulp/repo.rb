module Katello
  module Glue::Pulp::Repo
    # TODO: move into submodules
    # rubocop:disable MethodLength
    # rubocop:disable ModuleLength
    # rubocop:disable Metrics/AbcSize
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

        def self.ensure_sync_notification
          resource = Katello.pulp_server.resources.event_notifier
          url = SETTINGS[:katello][:post_sync_url]
          type = Runcible::Resources::EventNotifier::EventTypes::REPO_SYNC_COMPLETE
          notifs = resource.list

          #delete any similar tasks with the wrong url (in case it changed)
          notifs.select { |n| n['event_types'] == [type] && n['notifier_config']['url'] != url }.each do |e|
            resource.delete(e['id'])
          end

          #only create a notifier if one doesn't exist with the correct url
          exists = notifs.select { |n| n['event_types'] == [type] && n['notifier_config']['url'] == url }
          resource.create(Runcible::Resources::EventNotifier::NotifierTypes::REST_API, {:url => url}, [type]) if exists.empty?
        end

        def self.delete_orphaned_content
          Katello.pulp_server.resources.content.remove_orphans
        end

        def self.distribution_bootable?(distribution)
          # Not every distribution from Pulp represents a bootable
          # repo. Determine based on the files in the repo.
          distribution["files"].any? do |file|
            if file.is_a? Hash
              filename = file[:relativepath]
            else
              filename = file
            end
            filename.include?('vmlinuz') || filename.include?('pxeboot') || filename.include?('kernel.img') || filename.include?('initrd.img')
          end
        end

        def self.needs_importer_updates(repos, capsule_content)
          repos.select do |repo|
            repo_details = capsule_content.pulp_repo_facts(repo.pulp_id)
            next unless repo_details
            capsule_importer = repo_details["importers"][0]
            !repo.importer_matches?(capsule_importer, capsule_content.capsule)
          end
        end

        def self.needs_distributor_updates(repos, capsule_content)
          repos.select do |repo|
            repo_details = capsule_content.pulp_repo_facts(repo.pulp_id)
            next unless repo_details
            !repo.distributors_match?(repo_details["distributors"], capsule_content.capsule)
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

      def initialize(attrs = nil, options = {})
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
          super(attrs_used_by_model, options)
        end
      end

      def uri
        uri = URI.parse(SETTINGS[:katello][:pulp][:url])
        "https://#{uri.host}/pulp/repos/#{relative_path}"
      end

      def to_hash
        pulp_repo_facts.merge(as_json).merge(:sync_state => sync_state)
      end

      def pulp_checksum_type
        find_distributor['config']['checksum_type'] if self.try(:yum?) && find_distributor
      end

      def pulp_counts_differ?
        pulp_counts = pulp_repo_facts[:content_unit_counts]
        rpms.count != pulp_counts['rpm'].to_i ||
          errata.count != pulp_counts['erratum'].to_i ||
          package_groups.count != pulp_counts['package_group'].to_i ||
          puppet_modules.count != pulp_counts['puppet_module'].to_i ||
          docker_manifests.count != pulp_counts['docker_manifest'].to_i ||
          docker_tags.count != pulp_counts['docker_tag'].to_i ||
          ostree_branches.count != pulp_counts['ostree'].to_i
      end

      def create_pulp_repo
        #if we are in library, no need for an distributor, but need to sync
        if self.environment.try(:library?)
          importer = generate_importer
        else
          #if not in library, no need for sync info, but we need a distributor
          case self.content_type
          when Repository::YUM_TYPE
            importer = Runcible::Models::YumImporter.new
          when Repository::PUPPET_TYPE
            importer = Runcible::Models::PuppetImporter.new
          end
        end

        distributors = generate_distributors

        Katello.pulp_server.extensions.repository.create_with_importer_and_distributors(self.pulp_id,
                                                                                        importer,
                                                                                        distributors,
                                                                                        :display_name => self.name)
      rescue RestClient::ServiceUnavailable => e
        message = _("Pulp service unavailable during creating repository '%s', please try again later.") % self.name
        raise PulpErrors::ServiceUnavailable.new(message, e)
      end

      def generate_importer(capsule = nil)
        case self.content_type
        when Repository::YUM_TYPE
          Runcible::Models::YumImporter.new(yum_importer_values(capsule))
        when Repository::FILE_TYPE
          Runcible::Models::IsoImporter.new(importer_ssl_options(capsule).merge(:feed => importer_feed_url(capsule)))
        when Repository::PUPPET_TYPE
          options = {:feed => importer_feed_url(capsule)}
          Runcible::Models::PuppetImporter.new(importer_ssl_options(capsule).merge(options))
        when Repository::DOCKER_TYPE
          options = {}
          options[:upstream_name] = capsule ? self.pulp_id : self.docker_upstream_name
          options[:feed] = docker_feed_url(capsule)
          options[:enable_v1] = false
          Runcible::Models::DockerImporter.new(importer_ssl_options(capsule).merge(options))
        when Repository::OSTREE_TYPE
          options = importer_ssl_options(capsule)

          options[:feed] = self.importer_feed_url(capsule)
          Runcible::Models::OstreeImporter.new(options)
        else
          fail _("Unexpected repo type %s") % self.content_type
        end
      end

      def docker_feed_url(capsule = false)
        pulp_uri = URI.parse(SETTINGS[:katello][:pulp][:url])
        if capsule
          "https://#{pulp_uri.host.downcase}:#{Setting['pulp_docker_registry_port']}"
        else
          self.url if self.respond_to?(:url)
        end
      end

      def importer_feed_url(capsule = false)
        if capsule
          self.full_path(nil, true)
        else
          self.url if self.respond_to?(:url)
        end
      end

      def yum_importer_values(capsule)
        if capsule
          new_download_policy = capsule_download_policy(capsule)
        else
          new_download_policy = self.download_policy
        end

        config = {
          :feed => self.importer_feed_url(capsule),
          :download_policy => new_download_policy,
          :remove_missing => capsule ? true : self.mirror_on_sync?
        }
        config.merge(importer_ssl_options(capsule))
      end

      def importer_ssl_options(capsule = nil)
        if capsule
          ueber_cert = ::Cert::Certs.ueber_cert(organization)
          importer_options = {
            :ssl_client_cert => ueber_cert[:cert],
            :ssl_client_key => ueber_cert[:key],
            :ssl_ca_cert => ::Cert::Certs.ca_cert
          }
        elsif self.try(:redhat?) && self.content_view.default?
          importer_options = {
            :ssl_client_cert => self.product.certificate,
            :ssl_client_key => self.product.key,
            :ssl_ca_cert => Resources::CDN::CdnResource.ca_file_contents
          }
        else
          importer_options = {
            :ssl_client_cert => nil,
            :ssl_client_key => nil,
            :ssl_ca_cert => nil
          }
        end
        unless self.is_a?(::Katello::ContentViewPuppetEnvironment)
          importer_options.merge!(:ssl_validation => verify_ssl_on_sync?)
          importer_options[:basic_auth_username] = upstream_username if upstream_username.present?
          importer_options[:basic_auth_password] = upstream_password if upstream_password.present?
        end
        importer_options
      end

      def generate_distributors(capsule = nil)
        case self.content_type
        when Repository::YUM_TYPE
          yum_dist_id = self.pulp_id
          yum_dist_options = {:protected => true, :id => yum_dist_id, :auto_publish => true}
          #check the instance variable, as we do not want to go to pulp
          yum_dist_options['checksum_type'] = self.checksum_type
          yum_dist = Runcible::Models::YumDistributor.new(self.relative_path, self.unprotected, true,
                                                          yum_dist_options)
          clone_dist = Runcible::Models::YumCloneDistributor.new(:id => "#{self.pulp_id}_clone",
                                                                 :destination_distributor_id => yum_dist_id)
          export_dist = Runcible::Models::ExportDistributor.new(false, false, self.relative_path)
          distributors = [yum_dist, export_dist]
          distributors << clone_dist unless capsule
        when Repository::FILE_TYPE
          dist = Runcible::Models::IsoDistributor.new(true, true)
          dist.auto_publish = true
          distributors = [dist]
        when Repository::PUPPET_TYPE
          capsule ||= SmartProxy.default_capsule!
          dist_options = { :id => self.pulp_id, :auto_publish => true }
          repo_path =  File.join(capsule.puppet_path,
                                 Environment.construct_name(self.organization,
                                                            self.environment,
                                                            self.content_view),
                                 'modules')
          puppet_install_dist = Runcible::Models::PuppetInstallDistributor.new(repo_path, dist_options)

          dist_options[:id] = "#{self.pulp_id}_puppet"
          puppet_dist = Runcible::Models::PuppetDistributor.new(nil, (self.unprotected || false),
                                                                true, dist_options)

          distributors = [puppet_dist, puppet_install_dist]
        when Repository::DOCKER_TYPE
          options = { :protected => !self.unprotected, :id => self.pulp_id, :auto_publish => true}
          docker_dist = Runcible::Models::DockerDistributor.new(options)
          distributors = [docker_dist]
        when Repository::OSTREE_TYPE
          options = { :id => self.pulp_id,
                      :auto_publish => true,
                      :relative_path => relative_path }
          dist = Runcible::Models::OstreeDistributor.new(options)
          distributors = [dist]
        else
          fail _("Unexpected repo type %s") % self.content_type
        end

        distributors
      end

      def importer_type
        case self.content_type
        when Repository::YUM_TYPE
          Runcible::Models::YumImporter::ID
        when Repository::FILE_TYPE
          Runcible::Models::IsoImporter::ID
        when Repository::PUPPET_TYPE
          Runcible::Models::PuppetImporter::ID
        when Repository::DOCKER_TYPE
          Runcible::Models::DockerImporter::ID
        when Repository::OSTREE_TYPE
          Runcible::Models::OstreeImporter::ID
        else
          fail _("Unexpected repo type %s") % self.content_type
        end
      end

      def populate_from(repos_map)
        found = repos_map[self.pulp_id]
        prepopulate(found) if found
        !found.nil?
      end

      def other_repos_with_same_product_and_content
        Repository.where(:content_id => self.content_id).in_product(self.product).pluck(:pulp_id) - [self.pulp_id]
      end

      def other_repos_with_same_content
        Repository.where(:content_id => self.content_id).pluck(:pulp_id) - [self.pulp_id]
      end

      def package_group_count
        content_unit_counts = 0
        if self.pulp_repo_facts
          content_unit_counts = self.pulp_repo_facts[:content_unit_counts][:package_group]
        end
        content_unit_counts
      end

      # remove errata and groups from this repo
      # that have no packages
      def purge_empty_groups_errata
        package_lists = package_lists_for_publish
        rpm_names = package_lists[:names]
        filenames = package_lists[:filenames]

        # Remove all errata with no packages
        errata_to_delete = errata.collect do |erratum|
          erratum.errata_id if filenames.intersection(erratum.package_filenames).empty?
        end
        errata_to_delete.compact!

        #do the errata remove call
        unless errata_to_delete.empty?
          unassociate_by_filter(ContentViewErratumFilter::CONTENT_TYPE,
                                 "id" => { "$in" => errata_to_delete })
        end

        # Remove all  package groups with no packages
        package_groups_to_delete = package_groups.collect do |group|
          group.package_group_id if rpm_names.intersection(group.package_names).empty?
        end
        package_groups_to_delete.compact!

        unless package_groups_to_delete.empty?
          unassociate_by_filter(ContentViewPackageGroupFilter::CONTENT_TYPE,
                                 "id" => { "$in" => package_groups_to_delete })
        end
      end

      def sync_schedule(date_and_time)
        if date_and_time
          Katello.pulp_server.extensions.repository.create_or_update_schedule(self.pulp_id, importer_type, date_and_time)
        else
          Katello.pulp_server.extensions.repository.remove_schedules(self.pulp_id, importer_type)
        end
      end

      def find_packages_by_name(name)
        Katello.pulp_server.extensions.repository.rpms_by_nvre self.pulp_id, name
      end

      def find_packages_by_nvre(name, version, release, epoch)
        Katello.pulp_server.extensions.repository.rpms_by_nvre self.pulp_id, name, version, release, epoch
      end

      def pulp_update_needed?
        changeable_attributes = %w(url unprotected checksum_type docker_upstream_name download_policy mirror_on_sync verify_ssl_on_sync)
        changeable_attributes << "name" if docker?
        changeable_attributes.any? { |key| previous_changes.key?(key) }
      end

      def sync(options = {})
        sync_options = {}
        sync_options[:max_speed] ||= SETTINGS[:katello][:pulp][:sync_KBlimit] if SETTINGS[:katello][:pulp][:sync_KBlimit] # set bandwidth limit
        sync_options[:num_threads] ||= SETTINGS[:katello][:pulp][:sync_threads] if SETTINGS[:katello][:pulp][:sync_threads] # set threads per sync
        pulp_tasks = Katello.pulp_server.extensions.repository.sync(self.pulp_id, :override_config => sync_options)

        task = PulpSyncStatus.using_pulp_task(pulp_tasks) do |t|
          t.organization = organization
          t.parameters ||= {}
          t.parameters[:options] = options
        end
        task.save!
        return [task]
      end

      def clone_contents_by_filter(to_repo, content_type, filter_clauses, override_config = {})
        content_classes = {
          Katello::Rpm::CONTENT_TYPE => :rpm,
          Katello::PackageGroup::CONTENT_TYPE => :package_group,
          Katello::Erratum::CONTENT_TYPE => :errata,
          Katello::PuppetModule::CONTENT_TYPE => :puppet_module
        }
        fail "Invalid content type #{content_type} sent. It needs to be one of #{content_classes.keys}"\
                                                                       unless content_classes[content_type]
        criteria = {}
        if content_type == Runcible::Extensions::Rpm.content_type
          criteria[:fields] = Pulp::Rpm::PULP_SELECT_FIELDS
        end

        if filter_clauses && !filter_clauses.empty?
          if content_type == Runcible::Extensions::PuppetModule.content_type
            criteria[:filters] = {:association => filter_clauses}
          else
            criteria[:filters] = {:unit => filter_clauses}
          end
        end
        criteria[:override_config] = override_config unless override_config.empty?
        Katello.pulp_server.extensions.send(content_classes[content_type]).copy(self.pulp_id, to_repo.pulp_id, criteria)
      end

      def clone_contents(to_repo)
        events = []

        if self.content_type == Repository::PUPPET_TYPE
          events << Katello.pulp_server.extensions.puppet_module.copy(self.pulp_id, to_repo.pulp_id)
        else
          # In order to reduce the memory usage of pulp during the copy process,
          # include the fields that will uniquely identify the rpm. If no fields
          # are listed, pulp will retrieve every field it knows about for the rpm
          # (e.g. changelog, filelist...etc).
          events << Katello.pulp_server.extensions.rpm.copy(self.pulp_id, to_repo.pulp_id,
                                                    :fields => Pulp::Rpm::PULP_SELECT_FIELDS)

          # Since the rpms will be copied above, during the copy of errata and package groups,
          # include the copy_children flag to request that pulp skip copying them again.
          events << Katello.pulp_server.extensions.errata.copy(self.pulp_id, to_repo.pulp_id, :copy_children => false)
          events << Katello.pulp_server.extensions.package_group.copy(self.pulp_id, to_repo.pulp_id, :copy_children => false)
          events << clone_file_metadata(to_repo)
        end

        events
      end

      def clone_file_metadata(to_repo)
        Katello.pulp_server.extensions.yum_repo_metadata_file.copy(self.pulp_id, to_repo.pulp_id)
      end

      def unassociate_by_filter(content_type, filter_clauses)
        criteria = {:type_ids => [content_type], :filters => {:unit => filter_clauses}}
        if content_type == Katello.pulp_server.extensions.rpm.content_type
          criteria[:fields] = { :unit => Pulp::Rpm::PULP_SELECT_FIELDS}
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
         Katello.pulp_server.extensions.puppet_module
        ]
      end

      def sync_start
        status = self.sync_status
        retval = nil
        if status.nil? || status['progress']['start_time'].nil?
          retval = nil
        else
          retval = status['progress']['start_time']
          # retval = date.strftime("%H:%M:%S %Y-%m-%d")
        end
        retval
      end

      def sync_finish
        status = self.sync_status
        retval = nil
        if status.nil? || status['progress']['finish_time'].nil?
          retval = nil
        else
          retval = status['progress']['finish_time']
        end
        retval
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
        when Repository::PUPPET_TYPE
          "puppet_module"
        when Repository::DOCKER_TYPE
          "docker_manifest"
        when Repository::OSTREE_TYPE
          "ostree"
        when Repository::FILE_TYPE
          "iso"
        end
      end

      def unit_search(options = {})
        Katello.pulp_server.extensions.repository.unit_search(self.pulp_id, options)
      end

      # A helper method used by purge_empty_groups_errata
      # to obtain a list of package filenames and names
      # so that it could mix/match empty package groups
      # and errata and purge them.
      def package_lists_for_publish
        names = []
        filenames = []
        rpm_list = []
        rpm_ids = Katello::Pulp::Rpm.ids_for_repository(self)
        rpm_ids.each_slice(SETTINGS[:katello][:pulp][:bulk_load_size]) do |sub_list|
          rpm_list.concat(Katello.pulp_server.extensions.rpm.find_all_by_unit_ids(
                                  sub_list, %w(filename name), :include_repos => false))
        end

        rpm_list.each do |rpm|
          filenames << rpm["filename"]
          names << rpm["name"]
        end
        {:names => names.to_set,
         :filenames => filenames.to_set}
      end

      def docker?
        self.content_type == Repository::DOCKER_TYPE
      end

      def puppet?
        self.content_type == Repository::PUPPET_TYPE
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

      def capsule_download_policy(capsule)
        policy = capsule.download_policy || Setting[:default_proxy_download_policy]
        if self.yum?
          if policy == ::SmartProxy::DOWNLOAD_INHERIT
            (self.library_instance || self).download_policy
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

      def filtered_distribution_config_equal?(generated_config, actual_config)
        generated = generated_config.clone
        actual = actual_config.clone
        #We store 'default' checksum type as nil, but pulp will default to sha256, so if we haven't set it, ignore it
        if generated.keys.include?('checksum_type') && generated['checksum_type'].nil?
          generated.delete('checksum_type')
          actual.delete('checksum_type')
        end
        generated.delete('repo-registry-id')
        generated == actual
      end

      def importer_matches?(capsule_importer, capsule)
        generated_importer = self.generate_importer(capsule)
        capsule_importer.try(:[], 'importer_type_id') == generated_importer.id &&
          generated_importer.config == capsule_importer['config']
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

          if history.nil? || history.empty?
            history = PulpSyncStatus.convert_history(Katello.pulp_server.extensions.repository.sync_history(pulp_id))
          end
        rescue
          history = PulpSyncStatus.convert_history(Katello.pulp_server.extensions.repository.sync_history(pulp_id))
        end

        if history.nil? || history.empty?
          return PulpSyncStatus.new(:state => PulpSyncStatus::Status::NOT_SYNCED)
        else
          history = sort_sync_status(history)
          return PulpSyncStatus.pulp_task(history.first.with_indifferent_access)
        end
      end
    end

    def full_path(smart_proxy = nil, force_https = false)
      pulp_uri = URI.parse(smart_proxy ? smart_proxy.url : SETTINGS[:katello][:pulp][:url])
      scheme   = (self.unprotected && !force_https) ? 'http' : 'https'
      if docker?
        "#{pulp_uri.host.downcase}:#{Setting['pulp_docker_registry_port']}/#{pulp_id}"
      elsif file?
        "#{scheme}://#{pulp_uri.host.downcase}/pulp/isos/#{pulp_id}/"
      elsif puppet?
        "#{scheme}://#{pulp_uri.host.downcase}/pulp/puppet/#{pulp_id}/"
      elsif ostree?
        "#{scheme}://#{pulp_uri.host.downcase}/pulp/ostree/web/#{relative_path}"
      else
        "#{scheme}://#{pulp_uri.host.downcase}/pulp/repos/#{relative_path}/"
      end
    end

    def index_content
      if self.yum?
        Katello::Rpm.import_for_repository(self)
        Katello::Erratum.import_for_repository(self)
        Katello::PackageGroup.import_for_repository(self)
        self.import_distribution_data
      elsif self.docker?
        Katello::DockerManifest.import_for_repository(self)
        Katello::DockerTag.import_for_repository(self, true)
      elsif self.puppet?
        Katello::PuppetModule.import_for_repository(self)
      elsif self.ostree?
        Katello::OstreeBranch.import_for_repository(self)
      elsif self.file?
        Katello::FileUnit.import_for_repository(self)
      end
      true
    end
  end
end
