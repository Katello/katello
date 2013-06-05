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

module Glue::Pulp::Repo
  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do

      validates_with Validators::KatelloUrlFormatValidator,
                     :attributes => :feed,
                     :field_name => :url, :on => :create,
                     :if => Proc.new { |o| o.environment.library? && o.in_default_view?  }

      before_save :save_repo_orchestration
      before_destroy :destroy_repo_orchestration

      lazy_accessor :pulp_repo_facts,
                    :initializer => lambda { |s|
                      if pulp_id
                        Runcible::Extensions::Repository.retrieve_with_details(pulp_id)
                      end
                    }

      lazy_accessor :importers,
                    :initializer => lambda { |s|
                      pulp_repo_facts["importers"] if pulp_id
                    }

      lazy_accessor :distributors,
                    :initializer => lambda { |s|
                      pulp_repo_facts["distributors"] if pulp_id
                    }

      attr_accessor :feed_cert, :feed_key, :feed_ca

      def self.ensure_sync_notification
        resource =  Runcible::Resources::EventNotifier
        url = Katello.config.post_sync_url
        type = resource::EventTypes::REPO_SYNC_COMPLETE
        notifs = resource.list()

        #delete any similar tasks with the wrong url (in case it changed)
        notifs.select{|n| n['event_types'] == [type] && n['notifier_config']['url'] != url}.each do |e|
          resource.delete(e['id'])
        end

        #only create a notifier if one doesn't exist with the correct url
        exists = notifs.select{|n| n['event_types'] == [type] && n['notifier_config']['url'] == url}
        resource.create(resource::NotifierTypes::REST_API, {:url=>url}, [type]) if exists.empty?
      end

    end
  end

  module InstanceMethods
    def save_repo_orchestration
      case orchestration_for
        when :create
          pre_queue.create(:name => "create pulp repo: #{self.name}", :priority => 2, :action => [self, :create_pulp_repo])
      end
    end

    def last_sync
      self.importers.first["last_sync"] if self.importers.first
    end

    def initialize(attrs=nil, options={})
      if attrs.nil?
        super
      elsif
        type_key = attrs.has_key?('type') ? 'type' : :type
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
      pulp_repo_facts.merge(as_json).merge(:sync_state=> sync_state)
    end

    def create_pulp_repo
      #if we are in library, no need for an distributor, but need to sync
      if self.environment.library?
        importer = generate_importer
      else
        #if not in library, no need for sync info, but we need a distributor
        importer = Runcible::Extensions::YumImporter.new
      end

      distributors = [generate_distributor]

      Runcible::Extensions::Repository.create_with_importer_and_distributors(self.pulp_id,
          importer,
          distributors,
          {:display_name=>self.name})
    rescue RestClient::ServiceUnavailable => e
      message = _("Pulp service unavailable during creating repository '%s', please try again later.") % self.name
      raise PulpErrors::ServiceUnavailable.new(message, e)
    end


    def generate_importer
      case self.content_type
        when Repository::YUM_TYPE
          Runcible::Extensions::YumImporter.new(:ssl_ca_cert=>self.feed_ca,
                        :ssl_client_cert=>self.feed_cert,
                        :ssl_client_key=>self.feed_key,
                        :feed_url=>self.feed)
        when Repository::FILE_TYPE
          Runcible::Extensions::IsoImporter.new(:ssl_ca_cert=>self.feed_ca,
                        :ssl_client_cert=>self.feed_cert,
                        :ssl_client_key=>self.feed_key,
                        :feed_url=>self.feed)
        else
          raise _("Unexpected repo type %s") % self.content_type
      end
    end

    def generate_distributor
      case self.content_type
        when Repository::YUM_TYPE
          Runcible::Extensions::YumDistributor.new(self.relative_path, (self.unprotected || false), true,
                  {:protected=>true, :id=>self.pulp_id,
                      :auto_publish=>true})
        when Repository::FILE_TYPE
          dist = Runcible::Extensions::IsoDistributor.new(true, true)
          dist.auto_publish = true
          dist
        else
          raise _("Unexpected repo type %s") % self.content_type
      end
    end

    def refresh_pulp_repo(feed_ca, feed_cert, feed_key)
      self.feed_ca = feed_ca
      self.feed_cert = feed_cert
      self.feed_key = feed_key
      Runcible::Extensions::Repository.update_importer(self.pulp_id, self.importers.first['id'], generate_importer.config)
      Runcible::Extensions::Repository.update_distributor(self.pulp_id, self.distributors.first['id'], generate_distributor.config)
    end

    def promote from_env, to_env
      if self.is_cloned_in?(to_env)
        self.clone_contents(self.get_clone(to_env))
      else
        clone = self.create_clone(to_env)
        clone_events = self.clone_contents(clone) #return clone task
        #TODO ensure that clone content is indexed
        #clone.index_packages
        #clone.index_errata
        return clone_events
      end
    end

    def populate_from repos_map
      found = repos_map[self.pulp_id]
      prepopulate(found) if found
      !found.nil?
    end

    def destroy_repo
      Runcible::Extensions::Repository.delete(self.pulp_id)
      true
    end

    def other_repos_with_same_product_and_content
      Repository.where(:content_id=>self.content_id).in_product(self.product).pluck(:pulp_id) - [self.pulp_id]
    end

    def other_repos_with_same_content
      Repository.where(:content_id=>self.content_id).pluck(:pulp_id) - [self.pulp_id]
    end

    def destroy_repo_orchestration
      pre_queue.create(:name => "delete pulp repo : #{self.name}",       :priority => 3, :action => [self, :destroy_repo])
    end

    def package_ids
      Runcible::Extensions::Repository.rpm_ids(self.pulp_id)
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
      end.compact

      #do the errata remove call
      unless errata_to_delete.empty?
        unassociate_by_filter(FilterRule::ERRATA, {"id" => {"$in" => errata_to_delete}})
      end

      # Remove all  package groups with no packages
      package_groups_to_delete = package_groups.collect do |group|
        group.package_group_id if rpm_names.intersection(group.package_names).empty?
      end.compact

      unless package_groups_to_delete.empty?
        unassociate_by_filter(FilterRule::PACKAGE_GROUP, {"id" => {"$in" => package_groups_to_delete}})
      end
    end

    def packages
      if @repo_packages.nil?
        #we fetch ids and then fetch packages by id, because repo packages
        #  does not contain all the info we need (bz 854260)
        tmp_packages = []
        package_fields = ['name', 'version', 'release', 'arch', 'suffix', 'epoch',
                          'download_url', 'checksum', 'checksumtype', 'license', 'group',
                          'children', 'vendor', 'filename', 'relativepath', 'requires',
                          'provides', 'description', 'size', 'buildhost',
                          '_id', '_content_type_id', '_href', '_storage_path', '_type']

        self.package_ids.each_slice(Katello.config.pulp.bulk_load_size) do |sub_list|
          tmp_packages.concat(Runcible::Extensions::Rpm.find_all_by_unit_ids(sub_list, package_fields))
        end
        self.packages = tmp_packages
      end
      @repo_packages
    end

    def packages=attrs
      @repo_packages = attrs.collect do |package|
        ::Package.new(package)
      end
      @repo_packages
    end

    def errata
      if @repo_errata.nil?
        #we fetch ids and then fetch errata by id, because repo errata
        #  do not contain all the info we need (bz 854260)
        e_ids = Runcible::Extensions::Repository.errata_ids(self.pulp_id)
        tmp_errata = []
        e_ids.each_slice(Katello.config.pulp.bulk_load_size) do |sub_list|
          tmp_errata.concat(Runcible::Extensions::Errata.find_all_by_unit_ids(sub_list))
        end
        self.errata = tmp_errata
      end
      @repo_errata
    end

    def errata=attrs
      @repo_errata = attrs.collect do |erratum|
        ::Errata.new(erratum)
      end
      @repo_errata
    end

    def distributions
      if @repo_distributions.nil?
        self.distributions = Runcible::Extensions::Repository.distributions(self.pulp_id)
      end
      @repo_distributions
    end

    def distributions=attrs
      @repo_distributions = attrs.collect do |dist|
          ::Distribution.new(dist)
      end
      @repo_distributions
    end

    def package_groups
      if @repo_package_groups.nil?
        groups = Runcible::Extensions::Repository.package_groups(self.pulp_id)
        self.package_groups = groups
      end
      @repo_package_groups
    end

    def package_groups=attrs
      @repo_package_groups = attrs.collect do |group|
        ::PackageGroup.new(group)
      end
      @repo_package_groups
    end

    def package_groups_search(search_args = {})
      groups = package_groups
      unless search_args.empty?
        groups.delete_if do |group|
          group_attrs = group.as_json
          search_args.any?{ |attr,value| group_attrs[attr] != value }
        end
      end
      groups
    end

    def package_group_categories(search_args = {})
      categories = Runcible::Extensions::Repository.package_categories(self.pulp_id)
      unless search_args.empty?
        categories.delete_if do |category_attrs|
          search_args.any?{ |attr,value| category_attrs[attr] != value }
        end
      end
      categories
    end

    def has_distribution? id
      self.distributions.each {|distro|
        return true if distro.id == id
      }
      return false
    end

    def set_sync_schedule(date_and_time)
      type = Runcible::Extensions::YumImporter::ID
      if date_and_time
          Runcible::Extensions::Repository.create_or_update_schedule(self.pulp_id, type, date_and_time)
      else
        Runcible::Extensions::Repository.remove_schedules(self.pulp_id, type)
      end
    end

    def has_package? id
      self.package_ids.include?(id)
    end

    def find_packages_by_name name
      Runcible::Extensions::Repository.rpms_by_nvre self.pulp_id, name
    end

    def find_packages_by_nvre name, version, release, epoch
      Runcible::Extensions::Repository.rpms_by_nvre self.pulp_id, name, version, release, epoch
    end

    def find_latest_packages_by_name name
      packages = Runcible::Extensions::Repository.rpms_by_nvre(self.pulp_id, name)
      Util::Package.find_latest_packages(packages)
    end

    def has_erratum? errata_id
      self.errata.each do |err|
        return true if err.errata_id == errata_id
      end
      return false
    end

    def sync(options = { })
      sync_options= {}
      sync_options[:max_speed] ||= Katello.config.pulp.sync_KBlimit if Katello.config.pulp.sync_KBlimit # set bandwidth limit
      sync_options[:num_threads] ||= Katello.config.pulp.sync_threads if Katello.config.pulp.sync_threads # set threads per sync
      pulp_tasks = Runcible::Extensions::Repository.sync(self.pulp_id, {:override_config=>sync_options})
      pulp_task = pulp_tasks.select{|i| i['tags'].include?("pulp:action:sync")}.first.with_indifferent_access

      task      = PulpSyncStatus.using_pulp_task(pulp_task) do |t|
        t.organization         = self.environment.organization
        t.parameters ||= {}
        t.parameters[:options] = options
      end
      task.save!
      return [task]
    end

    def handle_sync_complete_task(task_id)
      #pulp_task =  Runcible::Resources::Task.poll(pulp_task_id)

      #if pulp_task.nil?
      #  Rails.logger.error("Sync_complete called for #{pulp_task_id}, but no task found.")
      #  return
      #end
      #
      #task = PulpTaskStatus.using_pulp_task(pulp_task)
      #task.user ||= User.current
      #task.organization ||= self.environment.organization
      #task.save!

      notify = task.parameters.try(:[], :options).try(:[], :notify)
      user = task.user
      if task.state == TaskStatus::Status::FINISHED
        if user && notify
          Notify.success _("Repository '%s' finished syncing successfully.") % [self.name],
                         :user => user, :organization => self.organization
        end
      elsif task.state == 'error'
        details = if task.progress.error_details.present?
                    task.progress.error_details.map { |error| error[:error].to_s }
                  else
                    task.result[:errors].flatten.map(&:chomp)
                  end.join("\n")

        Rails.logger.error("*** Sync error: " +  details)
        if user && notify
          Notify.error _("There were errors syncing repository '%s'. See notices page for more details.") % self.name,
                       details => details, :user => user, :organization => self.organization
        end
      end
    end

    def clone_contents to_repo
      events = []
      # In order to reduce the memory usage of pulp during the copy process,
      # include the fields that will uniquely identify the rpm. If no fields
      # are listed, pulp will retrieve every field it knows about for the rpm
      # (e.g. changelog, filelist...etc).
      events << Runcible::Extensions::Rpm.copy(self.pulp_id, to_repo.pulp_id,
                                               { :fields => ['name', 'epoch', 'version', 'release', 'arch',
                                                             'checksumtype', 'checksum'] })

      events << Runcible::Extensions::Distribution.copy(self.pulp_id, to_repo.pulp_id)

      # Since the rpms will be copied above, during the copy of errata and package groups,
      # include the copy_children flag to request that pulp skip copying them again.
      events << Runcible::Extensions::Errata.copy(self.pulp_id, to_repo.pulp_id, { :copy_children => false })
      events << Runcible::Extensions::PackageGroup.copy(self.pulp_id, to_repo.pulp_id, { :copy_children => false })
      events
    end

    def unassociate_by_filter(content_type, filter_clauses)
      content_unit = {
        Runcible::Extensions::Rpm.content_type() => Runcible::Extensions::Rpm,
        Runcible::Extensions::Errata.content_type() => Runcible::Extensions::Errata,
        Runcible::Extensions::PackageGroup.content_type() => Runcible::Extensions::PackageGroup,
        Runcible::Extensions::Distribution.content_type() => Runcible::Extensions::Distribution
      }
      content_unit[content_type].unassociate_from_repo(self.pulp_id, :unit => filter_clauses)
    end

    def clear_contents
      self.clear_content_indices if Katello.config.use_elasticsearch
      Runcible::Extensions::Repository.unassociate_units(self.pulp_id)
    end

    def sync_start
      status = self.sync_status
      retval = nil
      if status.nil? or status['progress']['start_time'].nil?
        retval = nil
      else
        retval = status['progress']['start_time']
        # retval = date.strftime("%H:%M:%S %Y-%m-%d")
      end
      retval
    end

    def add_packages pkg_id_list
      previous = self.environmental_instances(self.content_view).in_environment(self.environment.prior).first
      Runcible::Extensions::Rpm.copy(previous.pulp_id, self.pulp_id, {:ids=>pkg_id_list})
    end

    def add_errata errata_unit_id_list
      previous = self.environmental_instances(self.content_view).in_environment(self.environment.prior).first
      Runcible::Extensions::Errata.copy(previous.pulp_id, self.pulp_id, {:ids=>errata_unit_id_list})
    end

    def add_distribution distribution_id
      previous = self.environmental_instances(self.content_view).in_environment(self.environment.prior).first
      Runcible::Extensions::Distribution.copy(previous.pulp_id, self.pulp_id, {:ids=>[distribution_id]})
    end

    def delete_packages package_id_list
      Runcible::Extensions::Rpm.unassociate_unit_ids_from_repo(self.pulp_id, package_id_list)
    end

    def delete_errata errata_id_list
      Runcible::Extensions::Errata.unassociate_unit_ids_from_repo(self.pulp_id, errata_id_list)
    end

    def delete_distribution distribution_id
      Runcible::Extensions::Distribution.unassociate_ids_from_repo(self.pulp_id, [distribution_id])
    end

    def cancel_sync
      Rails.logger.info "Cancelling synchronization of repository #{self.pulp_id}"
      history = self.sync_status
      return if history.nil? || history.state == ::PulpSyncStatus::Status::NOT_SYNCED
      Runcible::Resources::Task.cancel(history.uuid)
    end

    def sync_finish
      status = self.sync_status
      retval = nil
      if status.nil? or status['progress']['finish_time'].nil?
        retval = nil
      else
        retval = status['progress']['finish_time']
      end
      retval
    end

    def sync_status
      self._get_most_recent_sync_status() if @sync_status.nil?
    end

    def sync_state
      status = sync_status
      return ::PulpSyncStatus::Status::NOT_SYNCED if status.nil?
      status.state
    end

    def synced?
      sync_history = self.sync_status
      !sync_history.nil? && successful_sync?(sync_history)
    end

    def successful_sync?(sync_history_item)
      sync_history_item['state'] == ::PulpTaskStatus::Status::FINISHED.to_s
    end

    def generate_metadata
      Runcible::Extensions::Repository.publish_all(self.pulp_id)
    end

    def sort_sync_status statuses
      statuses.sort!{|a,b|
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
      }
      return statuses
    end

    protected

    def _get_most_recent_sync_status()
      begin
        history = Runcible::Extensions::Repository.sync_status(pulp_id)

        if history.nil? or history.empty?
          history = PulpSyncStatus.convert_history(Runcible::Extensions::Repository.sync_history(pulp_id))
        end
      rescue => e
          history = PulpSyncStatus.convert_history(Runcible::Extensions::Repository.sync_history(pulp_id))
      end

      if history.nil? or history.empty?
        return ::PulpSyncStatus.new(:state => ::PulpSyncStatus::Status::NOT_SYNCED)
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

      rpms = Runcible::Extensions::Repository.unit_search(self.pulp_id,
                                                   :type_ids=>['rpm'],
                                                   :fields =>{:unit=>["filename", "name"]})

      rpms.each do |rpm|
        filenames << rpm["metadata"]["filename"]
        names << rpm["metadata"]["name"]
      end
      {:names=> names.to_set,
       :filenames => filenames.to_set}
    end


  end

end
