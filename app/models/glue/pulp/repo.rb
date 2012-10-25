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

module Glue::Pulp::Repo
  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do
      before_save :save_repo_orchestration
      before_destroy :destroy_repo_orchestration

      has_and_belongs_to_many :filters, :uniq => true

      lazy_accessor :pulp_repo_facts,
                    :initializer => lambda {|s|
                      if pulp_id
                        Runcible::Extensions::Repository.retrieve(pulp_id)
                      end
                    }
      lazy_accessor :importers, :distributors,
                :initializer => lambda {
                  if pulp_id
                      pulp_repo_facts
                  end
                }
      attr_accessor :feed, :feed_cert, :feed_key, :feed_ca

      def self.ensure_sync_notification
        resource =  Runcible::Resources::EventNotifier
        url = AppConfig.post_sync_url
        type = resource::EventTypes::REPO_SYNC_COMPLETE
        notifs = resource.list()

        #delete any similar tasks with the wrong url (in case it changed)
        notifs.select{|n| n['event_types'] == [type] && n['notifier_config']['url'] != url}.each do |e|
          resource.destroy(e['id'])
        end

        #only create a notifier if one doesn't exist with the correct url
        exists = notifs.select{|n| n['event_types'] == [type] && n['notifier_config']['url'] == url}
        resource.create(resource::NotifierTypes::REST_API, {:url=>url}, [type]) if exists.empty?
      end

    end
  end

  def self.repo_id product_label, repo_label, env_label, organization_label
    [organization_label, env_label, product_label, repo_label].compact.join("-").gsub(/[^-\w]/,"_")
  end

  module InstanceMethods
    def save_repo_orchestration
      case orchestration_for
        when :create
          pre_queue.create(:name => "create pulp repo: #{self.name}", :priority => 2, :action => [self, :create_pulp_repo])
      end
    end

    def last_sync
      self.importers.first['last_sync'] if self.importers.first
    end

    def relative_path
      return @relative_path if @relative_path
      self.distributors.first['config']['relative_url'] if self.distributors.first
    end

    def relative_path=(path)
      @relative_path = path
    end

    def initialize(attrs = nil)
      if attrs.nil?
        super
      elsif
        type_key = attrs.has_key?('type') ? 'type' : :type
        #rename "type" to "cp_type" (activerecord and candlepin variable name conflict)
        #if attrs.has_key?(type_key) && !(attrs.has_key?(:cp_type) || attrs.has_key?('cp_type'))
        #  attrs[:cp_type] = attrs[type_key]
        #end

        attrs_used_by_model = attrs.reject do |k, v|
          !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
        super(attrs_used_by_model)
      end
    end

    def uri
      uri = URI.parse(AppConfig.pulp.url)
      "https://#{uri.host}/pulp/repos/#{relative_path}"
    end

    def to_hash
      pulp_repo_facts.merge(as_json).merge(:sync_state=> sync_state)
    end

    def create_pulp_repo
      #if we are in library, no need for an distributor, but need to sync
      if self.environment.library?
        importer = Runcible::Extensions::YumImporter.new(:ssl_ca_cert=>self.feed_ca,
              :ssl_client_cert=>self.feed_cert,
              :ssl_client_key=>self.feed_key,
              :feed_url=>self.feed)
      else
        #if not in library, no need for sync info, but we need a distributor
        importer = Runcible::Extensions::YumImporter.new
      end

      distributors = self.enabled? ? [generate_distributor] : []

      Runcible::Extensions::Repository.create_with_importer_and_distributors(self.pulp_id,
          importer,
          distributors,
          {:display_name=>self.name})
    end

    def generate_distributor
      Runcible::Extensions::YumDistributor.new(self.relative_path, false, true,
        {:protected=>true, :generate_metadata=>true, :id=>self.pulp_id,
            :auto_publish=>!self.environment.library?})
    end

    def promote from_env, to_env

      if self.is_cloned_in?(to_env)
        return clone.sync
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


    def packages
      if @repo_packages.nil?
        #we fetch ids and then fetch packages by id, because repo packages
        #  does not contain all the info we need (bz 854260)
        pkg_ids = Runcible::Extensions::Repository.rpm_ids(self.pulp_id)
        self.packages = Runcible::Extensions::Rpm.find_all(pkg_ids)
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
        e_ids = Runcible::Extensions::Repository.errata_ids(self.pulp_id)
        self.errata = Runcible::Extensions::Errata.find_all_by_unit_ids(e_ids)
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

    def package_groups search_args = {}
      groups = Runcible::Extensions::Repository.package_groups(self.pulp_id)
      unless search_args.empty?
        groups.delete_if do |group_attrs|
          search_args.any?{ |attr,value| group_attrs[attr] != value }
        end
      end
      groups
    end

    def package_group_categories search_args = {}
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

    def clone_id(env)
      Glue::Pulp::Repo.repo_id(self.product.label, self.label, env.label, env.organization.label)
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
      self.packages.each {|pkg|
        return true if pkg.id == id
      }
      return false
    end

    def find_packages_by_name name
      Runcible::Extensions::Repository.packages_by_nvre self.pulp_id, name
    end

    def find_packages_by_nvre name, version, release, epoch
      Runcible::Extensions::Repository.packages_by_nvre self.pulp_id, name, version, release, epoch
    end

    def find_latest_packages_by_name name
      Katello::PackageUtils.find_latest_packages(Runcible::Extensions::Repository.packages_by_nvre(self.pulp_id, name))
    end

    def has_erratum? id
      self.errata.each {|err|
        return true if err.id == id
      }
      return false
    end

    def sync(options = { })
      sync_options= {}
      sync_options[:max_speed] ||= AppConfig.pulp.sync_KBlimit if AppConfig.pulp.sync_KBlimit # set bandwidth limit
      sync_options[:num_threads] ||= AppConfig.pulp.sync_threads if AppConfig.pulp.sync_threads # set threads per sync
      pulp_tasks = Runcible::Extensions::Repository.sync(self.pulp_id, sync_options)
      pulp_task = pulp_tasks.select{|i| i['tags'].include?("pulp:action:sync")}.first.with_indifferent_access

      task      = PulpSyncStatus.using_pulp_task(pulp_task) do |t|
        t.organization         = self.environment.organization
        t.parameters ||= {}
        t.parameters[:options] = options
      end
      task.save!
      return [task]
    end

    def after_sync pulp_task_id
      pulp_task =  Runcible::Resources::Task.poll(pulp_task_id)

      if pulp_task.nil?
        Rails.logger.error("Sync_complete called for #{pulp_task_id}, but no task found.")
        return
      end

      task = PulpTaskStatus.using_pulp_task(pulp_task)
      task.user ||= User.current
      task.organization ||= self.environment.organization
      task.save!
      self.sync_complete(task)
    end

    def create_clone to_env
      library = self.environment.library? ? self : self.library_instance
      raise _("Cannot clone repository from #{self.environment.name} to #{to_env.name}.  They are not sequential.") if to_env.prior != self.environment
      raise _("Repository has already been promoted to #{to_env}") if Repository.where(:library_instance_id=>library.id).in_environment(to_env).count > 0

      key = EnvironmentProduct.find_or_create(to_env, self.product)
      clone = Repository.new(:environment_product => key,
                             :cp_label => self.cp_label,
                             :library_instance=>library,
                             :label=>self.label,
                             :name=>self.name,
                             :arch=>self.arch,
                             :major=>self.major,
                             :minor=>self.minor,
                             :enable=>self.enabled,
                             :content_id=>self.content_id
                             )
      clone.pulp_id = clone.clone_id(to_env)
      clone.relative_path = Glue::Pulp::Repos.clone_repo_path(self, to_env)
      clone.save!
      return clone
    end

    def clone_contents to_repo
      filtered = to_repo.applicable_filters.collect{|f| f.package_list}.flatten
      events = []
      events << Runcible::Extensions::Repository.rpm_copy(self.pulp_id, to_repo.pulp_id,
                                            {:name_blacklist=>filtered})
      events << Runcible::Extensions::Repository.errata_copy(self.pulp_id, to_repo.pulp_id)
      events << Runcible::Extensions::Repository.distribution_copy(self.pulp_id, to_repo.pulp_id)
      events       
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
      blacklist = []
      self.applicable_filters.each{|f| blacklist += f.package_list}

      previous = self.environmental_instances.in_environment(self.environment.prior).first
      Runcible::Extensions::Repository.rpm_copy(previous.pulp_id, self.pulp_id,
                                                {:package_ids=>pkg_id_list, :name_blacklist=>blacklist})
    end

    def add_errata errata_id_list
      previous = self.environmental_instances.in_environment(self.environment.prior).first
      Runcible::Extensions::Repository.errata_copy(previous.pulp_id, self.pulp_id, {:errata_ids=>errata_id_list})
    end

    def add_distribution distribution_id
      previous = self.environmental_instances.in_environment(self.environment.prior).first
      Runcible::Extensions::Repository.distribution_copy(previous.pulp_id, self.pulp_id, {:errata_ids=>[distribution_id]})
    end

    def delete_packages package_id_list
      Runcible::Extensions::Repository.rpm_remove self.pulp_id,  package_id_list
    end

    def delete_errata errata_id_list
      Runcible::Extensions::Repository.errata_remove self.pulp_id,  errata_id_list
    end

    def delete_distribution distribution_id
      Runcible::Extensions::Repository.distribution_remove(self.pulp_id, distribution_id)
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
      sync_history_item['state'] == 'success'
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
          history = Runcible::Extensions::Repository.sync_history(pulp_id)
        end
      rescue Exception=>e
          history = Runcible::Extensions::Repository.sync_history(pulp_id)
      end

      if history.nil? or history.empty?
        return ::PulpSyncStatus.new(:state => ::PulpSyncStatus::Status::NOT_SYNCED)
      else
        history = sort_sync_status(history)
        return PulpSyncStatus.pulp_task(history.first.with_indifferent_access)
      end
    end

  end

end
