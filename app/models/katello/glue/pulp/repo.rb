#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
module Glue::Pulp::Repo

  # TODO: move into submodules
  # rubocop:disable MethodLength
  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do

      before_save :save_repo_orchestration
      before_destroy :destroy_repo_orchestration

      lazy_accessor :pulp_repo_facts,
                    :initializer => (lambda do |s|
                                       if pulp_id
                                         Katello.pulp_server.extensions.repository.retrieve_with_details(pulp_id)
                                       end
                                     end)

      lazy_accessor :checksum_type,
                    :initializer => lambda { |s| self.lookup_checksum_type if pulp_id}

      lazy_accessor :importers,
                    :initializer => lambda { |s| pulp_repo_facts["importers"] if pulp_id }

      lazy_accessor :distributors,
                    :initializer => lambda { |s| pulp_repo_facts["distributors"] if pulp_id }

      attr_accessor :feed_cert, :feed_key, :feed_ca

      def self.ensure_sync_notification
        resource =  Katello.pulp_server.resources.event_notifier
        url = Katello.config.post_sync_url
        type = Runcible::Resources::EventNotifier::EventTypes::REPO_SYNC_COMPLETE
        notifs = resource.list

        #delete any similar tasks with the wrong url (in case it changed)
        notifs.select{|n| n['event_types'] == [type] && n['notifier_config']['url'] != url}.each do |e|
          resource.delete(e['id'])
        end

        #only create a notifier if one doesn't exist with the correct url
        exists = notifs.select{ |n| n['event_types'] == [type] && n['notifier_config']['url'] == url }
        resource.create(Runcible::Resources::EventNotifier::NotifierTypes::REST_API, {:url => url}, [type]) if exists.empty?
      end

      def self.delete_orphaned_content
        Katello.pulp_server.resources.content.remove_orphans
      end

    end
  end

  module InstanceMethods
    def save_repo_orchestration
      case orchestration_for
      when :create
        pre_queue.create(:name => "create pulp repo: #{self.name}", :priority => 2, :action => [self, :create_pulp_repo])
      when :update
        if self.pulp_update_needed?
          pre_queue.create(:name => "update pulp repo: #{self.name}", :priority => 2,
                           :action => [self, :refresh_pulp_repo, nil, nil, nil])
        end
        if self.unprotected_changed?
          post_queue.create(:name => "generate metadata for pulp repo #{self.name}", :priority => 3, :action => [self, :generate_metadata])
        end
      end
    end

    def pulp_update_needed?
      (self.feed_changed? || self.unprotected_changed?) && !self.product.provider.redhat_provider?
    end

    def last_sync
      self.importers.first["last_sync"] if self.importers.first
    end

    def initialize(attrs = nil, options = {})
      if attrs.nil?
        super
      elsif
        #rename "type" to "cp_type" (activerecord and candlepin variable name conflict)
        #if attrs.has_key?(type_key) && !(attrs.has_key?(:cp_type) || attrs.has_key?('cp_type'))
        #  attrs[:cp_type] = attrs[type_key]
        #end

        attrs_used_by_model = attrs.reject do |k, v|
          !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
        super(attrs_used_by_model, options)
      end
    end

    def uri
      uri = URI.parse(Katello.config.pulp.url)
      "https://#{uri.host}/pulp/repos/#{relative_path}"
    end

    def to_hash
      pulp_repo_facts.merge(as_json).merge(:sync_state => sync_state)
    end

    def lookup_checksum_type
      find_distributor['config']['checksum_type'] if self.yum? && find_distributor
    end

    def create_pulp_repo
      #if we are in library, no need for an distributor, but need to sync
      if self.environment && self.environment.library?
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
          {:display_name => self.name})
    rescue RestClient::ServiceUnavailable => e
      message = _("Pulp service unavailable during creating repository '%s', please try again later.") % self.name
      raise PulpErrors::ServiceUnavailable.new(message, e)
    end

    def generate_importer
      case self.content_type
      when Repository::YUM_TYPE
        Runcible::Models::YumImporter.new(:ssl_ca_cert => self.feed_ca,
                                          :ssl_client_cert => self.feed_cert,
                                          :ssl_client_key => self.feed_key,
                                          :feed => self.feed)
      when Repository::FILE_TYPE
        Runcible::Models::IsoImporter.new(:ssl_ca_cert => self.feed_ca,
                                          :ssl_client_cert => self.feed_cert,
                                          :ssl_client_key => self.feed_key,
                                          :feed => self.feed)
      when Repository::PUPPET_TYPE
        Runcible::Models::PuppetImporter.new(:feed => self.feed)
      else
        fail _("Unexpected repo type %s") % self.content_type
      end
    end

    def generate_distributors
      case self.content_type
      when Repository::YUM_TYPE
        yum_dist_id = self.pulp_id
        yum_dist_options = {:protected => true, :id => yum_dist_id, :auto_publish => true}
        #check the instance variable, as we do not want to go to pulp
        yum_dist_options['checksum_type'] = self.checksum_type if self.instance_variable_get('@checksum_type')
        yum_dist = Runcible::Models::YumDistributor.new(self.relative_path, (self.unprotected || false), true,
                                                        yum_dist_options)
        clone_dist = Runcible::Models::YumCloneDistributor.new(:id => "#{self.pulp_id}_clone",
                                                               :destination_distributor_id => yum_dist_id)
        [yum_dist, clone_dist, nodes_distributor]
      when Repository::FILE_TYPE
        dist = Runcible::Models::IsoDistributor.new(true, true)
        dist.auto_publish = true
        [dist]
      when Repository::PUPPET_TYPE
        repo_path =  File.join(Katello.config.puppet_repo_root,
                               Environment.construct_name(self.environment.organization,
                                                          self.environment,
                                                          self.content_view),
                               'modules')
        puppet_install_dist =
            Runcible::Models::PuppetInstallDistributor.new(repo_path,
                                                           {:id => self.pulp_id, :auto_publish => true})
        [puppet_install_dist, nodes_distributor]
      else
        fail _("Unexpected repo type %s") % self.content_type
      end
    end

    def nodes_distributor
      Runcible::Models::NodesHttpDistributor.new(:id => "#{self.pulp_id}_nodes", :auto_publish => true)
    end

    def importer_type
      case self.content_type
      when Repository::YUM_TYPE
        Runcible::Models::YumImporter::ID
      when Repository::FILE_TYPE
        Runcible::Models::IsoImporter::ID
      when Repository::PUPPET_TYPE
        Runcible::Models::PuppetImporter::ID
      else
        fail _("Unexpected repo type %s") % self.content_type
      end
    end

    def refresh_pulp_repo(feed_ca, feed_cert, feed_key)
      self.feed_ca = feed_ca
      self.feed_cert = feed_cert
      self.feed_key = feed_key

      Katello.pulp_server.extensions.repository.update_importer(self.pulp_id, self.importers.first['id'], generate_importer.config)

      existing_distributors = self.distributors
      generate_distributors.each do |distributor|
        found = existing_distributors.select{ |i| i['distributor_type_id'] == distributor.type_id }.first
        if found
          Katello.pulp_server.extensions.repository.update_distributor(self.pulp_id, found['id'], distributor.config)
        else
          Katello.pulp_server.extensions.repository.associate_distributor(self.pulp_id, distributor.type_id, distributor.config,
                                                                 {:distributor_id => distributor.id})
        end
      end
    end

    def populate_from(repos_map)
      found = repos_map[self.pulp_id]
      prepopulate(found) if found
      !found.nil?
    end

    def generate_applicability
      task = Katello.pulp_server.extensions.repository.regenerate_applicability_by_ids([self.pulp_id])
      PulpTaskStatus.using_pulp_task(task)
    end

    def destroy_repo
      Katello.pulp_server.extensions.repository.delete(self.pulp_id)
      true
    end

    def other_repos_with_same_product_and_content
      Repository.where(:content_id => self.content_id).in_product(self.product).pluck(:pulp_id) - [self.pulp_id]
    end

    def other_repos_with_same_content
      Repository.where(:content_id => self.content_id).pluck(:pulp_id) - [self.pulp_id]
    end

    def destroy_repo_orchestration
      pre_queue.create(:name => "delete pulp repo : #{self.name}", :priority => 3, :action => [self, :destroy_repo])
    end

    def package_ids
      Katello.pulp_server.extensions.repository.rpm_ids(self.pulp_id)
    end

    def errata_ids
      Katello.pulp_server.extensions.repository.errata_ids(self.pulp_id)
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
        unassociate_by_filter(FilterRule::ERRATA, {"id" => {"$in" => errata_to_delete}})
      end

      # Remove all  package groups with no packages
      package_groups_to_delete = package_groups.collect do |group|
        group.package_group_id if rpm_names.intersection(group.package_names).empty?
      end
      package_groups_to_delete.compact!

      unless package_groups_to_delete.empty?
        unassociate_by_filter(FilterRule::PACKAGE_GROUP, {"id" => {"$in" => package_groups_to_delete}})
      end
    end

    def packages
      #we fetch ids and then fetch packages by id, because repo packages
      #  does not contain all the info we need (bz 854260)
      tmp_packages = []
      package_fields = %w(name version release arch suffix epoch
                          download_url checksum checksumtype license group
                          children vendor filename relativepath description
                          size buildhost _id _content_type_id _href
                          _storage_path _type _last_updated)

      self.package_ids.each_slice(Katello.config.pulp.bulk_load_size) do |sub_list|
        tmp_packages.concat(Katello.pulp_server.extensions.rpm.find_all_by_unit_ids(sub_list, package_fields))
      end
      self.packages = tmp_packages

      @repo_packages
    end

    def packages=(attrs)
      @repo_packages = attrs.collect do |package|
        Katello::Package.new(package)
      end
      @repo_packages
    end

    def errata
      if @repo_errata.nil?
        #we fetch ids and then fetch errata by id, because repo errata
        #  do not contain all the info we need (bz 854260)
        tmp_errata = []
        self.errata_ids.each_slice(Katello.config.pulp.bulk_load_size) do |sub_list|
          tmp_errata.concat(Katello.pulp_server.extensions.errata.find_all_by_unit_ids(sub_list))
        end
        self.errata = tmp_errata
      end
      @repo_errata
    end

    def errata=(attrs)
      @repo_errata = attrs.collect do |erratum|
        Katello::Errata.new(erratum)
      end
      @repo_errata
    end

    def distributions
      if @repo_distributions.nil?
        self.distributions = Katello.pulp_server.extensions.repository.distributions(self.pulp_id)
      end
      @repo_distributions
    end

    def distributions=(attrs)
      @repo_distributions = attrs.collect do |dist|
        Katello::Distribution.new(dist)
      end
      @repo_distributions
    end

    def bootable_distribution
      return unless self.unprotected

      # Not every distribution from Pulp represents a bootable
      # repo. Determine based on the files in the repo.
      return self.distributions.find do |distribution|
        distribution.files.any? do |file|
          file[:relativepath].include?("vmlinuz") ||
              file[:relativepath].include?("pxeboot")
        end
      end
    end

    def package_groups
      if @repo_package_groups.nil?
        groups = Katello.pulp_server.extensions.repository.package_groups(self.pulp_id)
        self.package_groups = groups
      end
      @repo_package_groups
    end

    def package_groups=(attrs)
      @repo_package_groups = attrs.collect do |group|
        Katello::PackageGroup.new(group)
      end
      @repo_package_groups
    end

    def package_groups_search(search_args = {})
      groups = package_groups
      unless search_args.empty?
        groups.delete_if do |group|
          group_attrs = group.as_json
          search_args.any?{ |attr, value| group_attrs[attr] != value }
        end
      end
      groups
    end

    def package_group_categories(search_args = {})
      categories = Katello.pulp_server.extensions.repository.package_categories(self.pulp_id)
      unless search_args.empty?
        categories.delete_if do |category_attrs|
          search_args.any?{ |attr, value| category_attrs[attr] != value }
        end
      end
      categories
    end

    def puppet_modules
      if @repo_puppet_modules.nil?
        # we fetch ids and then fetch modules by id, because repo puppet modules
        #  do not contain all the info we need
        ids = Katello.pulp_server.extensions.repository.puppet_module_ids(self.pulp_id)
        tmp_modules = []
        ids.each_slice(Katello.config.pulp.bulk_load_size) do |sub_list|
          tmp_modules.concat(Katello.pulp_server.extensions.puppet_module.find_all_by_unit_ids(sub_list))
        end
        self.puppet_modules = tmp_modules
      end
      @repo_puppet_modules
    end

    def puppet_modules=(attrs)
      @repo_puppet_modules = attrs.collect do |puppet_module|
        Katello::PuppetModule.new(puppet_module)
      end
      @repo_puppet_modules
    end

    def has_distribution?(id)
      self.distributions.each do |distro|
        return true if distro.id == id
      end
      return false
    end

    def set_sync_schedule(date_and_time)
      if date_and_time
        Katello.pulp_server.extensions.repository.create_or_update_schedule(self.pulp_id, importer_type, date_and_time)
      else
        Katello.pulp_server.extensions.repository.remove_schedules(self.pulp_id, importer_type)
      end
    end

    def has_package?(id)
      self.package_ids.include?(id)
    end

    def find_packages_by_name(name)
      Katello.pulp_server.extensions.repository.rpms_by_nvre self.pulp_id, name
    end

    def find_packages_by_nvre(name, version, release, epoch)
      Katello.pulp_server.extensions.repository.rpms_by_nvre self.pulp_id, name, version, release, epoch
    end

    def find_latest_packages_by_name(name)
      packages = Katello.pulp_server.extensions.repository.rpms_by_nvre(self.pulp_id, name)
      Util::Package.find_latest_packages(packages)
    end

    def has_erratum?(errata_id)
      self.errata.each do |err|
        return true if err.errata_id == errata_id
      end
      return false
    end

    def sync(options = {})
      sync_options = {}
      sync_options[:max_speed] ||= Katello.config.pulp.sync_KBlimit if Katello.config.pulp.sync_KBlimit # set bandwidth limit
      sync_options[:num_threads] ||= Katello.config.pulp.sync_threads if Katello.config.pulp.sync_threads # set threads per sync
      pulp_tasks = Katello.pulp_server.extensions.repository.sync(self.pulp_id, {:override_config => sync_options})
      pulp_task = pulp_tasks.select{ |i| i['tags'].include?("pulp:action:sync") }.first.with_indifferent_access

      task = PulpSyncStatus.using_pulp_task(pulp_task) do |t|
        t.organization = organization
        t.parameters ||= {}
        t.parameters[:options] = options
      end
      task.save!
      return [task]
    end

    def handle_sync_complete_task(pulp_task_id, notifier_service = Notify)
      pulp_task =  Katello.pulp_server.resources.task.poll(pulp_task_id)

      if pulp_task.nil?
        Rails.logger.error("Sync_complete called for #{pulp_task_id}, but no task found.")
        return
      end

      task = PulpTaskStatus.using_pulp_task(pulp_task)
      task.user ||= User.current
      task.organization ||= organization
      task.save!

      notify = task.parameters.try(:[], :options).try(:[], :notify)
      user = task.user
      if task.state == TaskStatus::Status::FINISHED.to_s && task.progress.error_details[:messages].blank?
        if user && notify
          notifier_service.success _("Repository '%s' finished syncing successfully.") % [self.name],
                         :user => user, :organization => self.organization
        end
      else
        details = []

        if task.progress.error_details.present?
          details = task.progress.error_details[:details].map do |error|
            error[:error_message].to_s
          end
        else
          details = task.result[:errors].flatten.map(&:chomp)
        end

        details = details.join("\n")

        Rails.logger.error("*** Sync error: " +  details)
        if user && notify
          notifier_service.error _("There were errors syncing repository '%s'. See notices page for more details.") % self.name,
                       :details => details, :user => user, :organization => self.organization
        end
      end
    end

    def clone_contents_by_filter(to_repo, content_type, filter_clauses, override_config = {})
      content_classes = {
          Katello::Package::CONTENT_TYPE => :rpm,
          Katello::PackageGroup::CONTENT_TYPE => :package_group,
          Katello::Errata::CONTENT_TYPE => :errata,
          Katello::PuppetModule::CONTENT_TYPE => :puppet_module
      }
      fail "Invalid content type #{content_type} sent. It needs to be one of #{content_classes.keys}"\
                                                                     unless content_classes[content_type]
      criteria = {}
      if content_type == Runcible::Extensions::Rpm.content_type
        criteria[:fields] = Package::PULP_SELECT_FIELDS
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
                                                 { :fields => Package::PULP_SELECT_FIELDS })
        events << clone_distribution(to_repo)

        # Since the rpms will be copied above, during the copy of errata and package groups,
        # include the copy_children flag to request that pulp skip copying them again.
        events << Katello.pulp_server.extensions.errata.copy(self.pulp_id, to_repo.pulp_id, { :copy_children => false })
        events << Katello.pulp_server.extensions.package_group.copy(self.pulp_id, to_repo.pulp_id, { :copy_children => false })
        events << clone_file_metadata(to_repo)
      end

      events
    end

    def clone_file_metadata(to_repo)
      Katello.pulp_server.extensions.yum_repo_metadata_file.copy(self.pulp_id, to_repo.pulp_id)
    end

    def clone_distribution(to_repo)
      Katello.pulp_server.extensions.distribution.copy(self.pulp_id, to_repo.pulp_id)
    end

    def unassociate_by_filter(content_type, filter_clauses)

      criteria = {:type_ids => [content_type], :filters => {:unit => filter_clauses}}
      if content_type == Katello.pulp_server.extensions.rpm.content_type
        criteria[:fields] = { :unit => Package::PULP_SELECT_FIELDS}
      end
      Katello.pulp_server.extensions.repository.unassociate_units(self.pulp_id, criteria)
    end

    def clear_contents
      self.clear_content_indices if Katello.config.use_elasticsearch
      tasks = content_types.collect { |type| type.unassociate_from_repo(self.pulp_id, {}) }.flatten(1)

      tasks << Katello.pulp_server.extensions.repository.unassociate_units(self.pulp_id,
                 {:type_ids => ['rpm'], :filters => {}, :fields => { :unit => Package::PULP_SELECT_FIELDS}})
      tasks
    end

    def content_types
      [Katello.pulp_server.extensions.errata,
       Katello.pulp_server.extensions.package_group,
       Katello.pulp_server.extensions.distribution,
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

    def cancel_sync
      Rails.logger.info "Cancelling synchronization of repository #{self.pulp_id}"
      history = self.sync_status
      return if history.nil? || !history.pending?
      Katello.pulp_server.resources.task.cancel(history.uuid)
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

    def generate_metadata(options = {})
      force_regeneration = options.fetch(:force_regeneration, false)
      cloned_repo_override = options.fetch(:cloned_repo_override, nil)
      tasks = []
      clone = cloned_repo_override || self.content_view_version.repositories.where(:library_instance_id => self.library_instance_id).where("id != #{self.id}").first
      if force_regeneration || self.content_view.default? || (self.content_view.nil? && !cloned_repo_override)
        tasks << self.publish_distributor
      else
        tasks << self.publish_clone_distributor(clone)
      end
      if self.find_node_distributor
        if options[:node_publish_async]
          self.async(:organization => self.organization,
                           :task_type => TaskStatus::TYPES[:content_view_node_publish][:type]).publish_node_distributor
        else
          tasks << self.publish_node_distributor
        end
      end
      tasks
    end

    def publish_distributor
      dist = find_distributor
      Katello.pulp_server.extensions.repository.publish(self.pulp_id, dist['id'])
    end

    def publish_node_distributor
      dist = self.find_node_distributor
      task = Katello.pulp_server.extensions.repository.publish(self.pulp_id, dist['id'])
      PulpTaskStatus.wait_for_tasks([task])
      Glue::Event.trigger(Katello::Actions::Repository::NodeMetadataGenerate, self)
    end

    def publish_clone_distributor(source_repo)
      dist = find_distributor(true)
      source_dist = source_repo.find_distributor

      fail "Could not find #{self.content_type} clone distributor for #{self.pulp_id}" if dist.nil?
      fail "Could not find #{self.content_type} distributor for #{source_repo.pulp_id}" if source_dist.nil?
      Katello.pulp_server.extensions.repository.publish(self.pulp_id, dist['id'],
                               :override_config => {:source_repo_id => source_repo.pulp_id,
                                                    :source_distributor_id => source_dist['id']})
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

    def find_node_distributor
      self.distributors.detect{|i| i["distributor_type_id"] == Runcible::Models::NodesHttpDistributor.type_id}
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

    def upload_content(filepath)
      case content_type
      when "puppet"
        unit_key, unit_metadata = Katello::PuppetModule.generate_unit_data(filepath)
      else
        fail _("Uploads not supported for content type '%s'.") % content_type
      end

      upload_id = Katello.pulp_server.resources.content.create_upload_request["upload_id"]

      File.open(filepath, "rb") do |file|
        offset = 0
        while (chunk = file.read(Katello.config.pulp.upload_chunk_size))
          Katello.pulp_server.resources.content.upload_bits(upload_id, offset, chunk)
          offset += Katello.config.pulp.upload_chunk_size
        end
      end

      Katello.pulp_server.resources.content.import_into_repo(self.pulp_id, unit_type_id,
                                                             upload_id, unit_key,
                                                             {:unit_metadata => unit_metadata}
                                                            )

      Katello.pulp_server.resources.content.delete_upload_request(upload_id)
      self.trigger_contents_changed(:index_units => [unit_key], :wait => false, :reindex => false)
    end

    def unit_type_id
      case content_type
      when Repository::YUM_TYPE
        "rpm"
      when Repository::PUPPET_TYPE
        "puppet_module"
      end
    end

    def unit_search(options = {})
      Katello.pulp_server.extensions.repository.unit_search(self.pulp_id, options)
    end

    protected

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

    # A helper method used by purge_empty_groups_errata
    # to obtain a list of package filenames and names
    # so that it could mix/match empty package groups
    # and errata and purge them.
    def package_lists_for_publish
      names = []
      filenames = []

      rpms = Katello.pulp_server.extensions.repository.unit_search(self.pulp_id,
                                                                   :type_ids => ['rpm'],
                                                                   :fields => {:unit => %w(filename name)})

      rpms.each do |rpm|
        filenames << rpm["metadata"]["filename"]
        names << rpm["metadata"]["name"]
      end
      {:names => names.to_set,
       :filenames => filenames.to_set}
    end

  end

  def full_path
    pulp_uri = URI.parse(Katello.config.pulp.url)
    scheme   = (self.unprotected ? 'http' : 'https')
    "#{scheme}://#{pulp_uri.host.downcase}/pulp/repos/#{relative_path}"
  end
end
end
