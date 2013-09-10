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

module Glue::Pulp::Consumer
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, LazyAccessor

    base.class_eval do
      before_save    :save_pulp_orchestration
      before_destroy :destroy_pulp_orchestration
      after_rollback :rollback_on_pulp_create, :on => :create

      add_system_group_hook     lambda { |system_group| system_group.add_consumer(self) }
      remove_system_group_hook  lambda { |system_group| system_group.remove_consumer(self) }

      lazy_accessor :pulp_facts, :initializer => lambda {|s| Katello.pulp_server.extensions.consumer.retrieve(uuid) }
      lazy_accessor :package_profile, :initializer => lambda{|s| fetch_package_profile}
      lazy_accessor :simple_packages, :initializer => (lambda do |s|
                                                         fetch_package_profile["profile"].
                                                           collect{|package| Glue::Pulp::SimplePackage.new(package)}
                                                       end)
      lazy_accessor :errata, :initializer => (lambda do |s|
                                                Katello.pulp_server.extensions.consumer.applicable_errata(uuid).
                                                  map{|k, v| v.values}.flatten.map{|e| ::Errata.new(e[:details])}
                                              end)
    end
  end

  module InstanceMethods

    def bound_yum_repos
      bindings(Runcible::Models::YumDistributor.type_id)
    end

    def bound_node_repos
      bindings(Runcible::Models::NodesHttpDistributor.type_id)
    end

    def bindings(type_id)
      bindings = Katello.pulp_server.extensions.consumer.retrieve_bindings(uuid)
      bindings.select{ |b| b['type_id'] == type_id }.collect{ |repo| repo["repo_id"] }
    end

    def enable_yum_repos(repo_ids)
      enable_repos(Runcible::Models::YumDistributor.type_id, bound_yum_repos, repo_ids, {:notify_agent => false})
    end

    def enable_node_repos(repo_ids)
      enable_repos(Runcible::Models::NodesHttpDistributor.type_id, bound_node_repos, repo_ids,
                   {:notify_agent => false, :binding_config => {:strategy => 'mirror'}})
    end

    # Binds and unbinds distributors of a certain type across repos
    # TODO: break up method
    # rubocop:disable MethodLength
    def enable_repos(distributor_type, existing_ids, update_ids, bind_options = {})
      # calculate repoids to bind/unbind
      bound_ids     = existing_ids
      intersection  = update_ids & bound_ids
      bind_ids      = update_ids - intersection
      unbind_ids    = bound_ids - intersection

      Rails.logger.debug "Bound #{} repo ids: #{bound_ids.inspect}"
      Rails.logger.debug "Update #{} repo ids: #{update_ids.inspect}"
      Rails.logger.debug "Repo ids to bind: #{bind_ids.inspect}"
      Rails.logger.debug "Repo ids to unbind: #{unbind_ids.inspect}"

      processed_ids = []
      error_ids     = []
      events = []

      unbind_ids.each do |repoid|
        begin
          events.concat(Katello.pulp_server.extensions.consumer.unbind_all(uuid,  repoid, distributor_type))
          processed_ids << repoid
        rescue => e
          Rails.logger.error "Failed to unbind repo #{repoid}: #{e}, #{e.backtrace.join("\n")}"
          error_ids << repoid
        end
      end

      bind_ids.each do |repoid|
        begin
          events.concat(Katello.pulp_server.extensions.consumer.bind_all(uuid, repoid, distributor_type, bind_options))
          processed_ids << repoid
        rescue => e
          Rails.logger.error "Failed to bind repo #{repoid}: #{e}, #{e.backtrace.join("\n")}"
          error_ids << repoid
        end
      end

      begin
        #the consumer user does not have access to check tasks in pulp
        #   so we have to switch to the hidden user temporarily
        previous_user = ::User.current
        ::User.current = ::User.hidden.first
        #reject agent bind events, and wait for others
        events.reject! do |event|
          all_events = %w(pulp:action:agent_bind pulp:action:agent_unbind pulp:action:delete_binding)
          !(event['tags'] & all_events).empty?
        end
        tasks = PulpTaskStatus.wait_for_tasks(events)
        tasks.each{|task| Rails.logger.error(task.error) if task.error?}
        return [processed_ids, error_ids]
      rescue => e
        Rails.logger.error "Failed to enable repositories: #{e}, #{e.backtrace.join("\n")}"
        raise e
      ensure
        ::User.current = previous_user
      end
    end

    def del_pulp_consumer
      Rails.logger.debug "Deleting consumer in pulp: #{self.name}"
      Katello.pulp_server.extensions.consumer.delete(self.uuid)
    rescue => e
      Rails.logger.error "Failed to delete pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def destroy_pulp_orchestration
      return true if self.is_a? Hypervisor
      pre_queue.create(:name => "delete pulp consumer: #{self.name}", :priority => 3, :action => [self, :del_pulp_consumer])
    end

    # A rollback occurred while attempting to create the consumer; therefore, perform necessary cleanup.
    def rollback_on_pulp_create
      del_pulp_consumer
    end

    def set_pulp_consumer
      Rails.logger.debug "Creating a consumer in pulp: #{self.name}"
      return Katello.pulp_server.extensions.consumer.create(self.uuid, {:display_name => self.name})
    rescue => e
      Rails.logger.error "Failed to create pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_pulp_consumer
      return true if @changed_attributes.empty?

      Rails.logger.debug "Updating consumer in pulp: #{self.name}"
      Katello.pulp_server.extensions.consumer.update(self.uuid, :display_name => self.name)
    rescue => e
      Rails.logger.error "Failed to update pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def upload_package_profile(profile)
      Rails.logger.debug "Uploading package profile for consumer #{self.name}"
      Katello.pulp_server.extensions.consumer.upload_profile(self.uuid, 'rpm', profile)
    rescue => e
      Rails.logger.error "Failed to upload package profile to pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_package(packages)
      Rails.logger.debug "Scheduling package install for consumer #{self.name}"
      Katello.pulp_server.extensions.consumer.install_content(self.uuid, 'rpm', packages, {"importkeys" => true})
    rescue => e
      Rails.logger.error "Failed to schedule package install for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package(packages)
      Rails.logger.debug "Scheduling package uninstall for consumer #{self.name}"
      Katello.pulp_server.extensions.consumer.uninstall_content(self.uuid, 'rpm', packages)
    rescue => e
      Rails.logger.error "Failed to schedule package uninstall for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_package(packages)
      Rails.logger.debug "Scheduling package update for consumer #{self.name}"
      options = {"importkeys" => true}
      options[:all] = true if packages.blank?
      Katello.pulp_server.extensions.consumer.update_content(self.uuid, 'rpm', packages, options)
    rescue => e
      Rails.logger.error "Failed to schedule package update for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def sync_pulp_node(repoids = nil)
      if repoids.nil?
        Rails.logger.debug "Scheduling full node update for consumer #{self.name}"
        Katello.pulp_server.extensions.consumer.update_content(self.uuid, 'node',  nil, {})
      else
        Rails.logger.debug "Scheduling partial node update for consumer #{self.name}"
        Katello.pulp_server.extensions.consumer.update_content(self.uuid, 'repository',  repoids, {})
      end
    rescue => e
      Rails.logger.error "Failed to schedule node update for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_package_group(groups)
      Rails.logger.debug "Scheduling package group install for consumer #{self.name}"
      Katello.pulp_server.extensions.consumer.install_content(self.uuid, 'package_group', groups, {"importkeys" => true})
    rescue => e
      Rails.logger.error "Failed to schedule package group install for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package_group(groups)
      Rails.logger.debug "Scheduling package group uninstall for consumer #{self.name}"
      Katello.pulp_server.extensions.consumer.uninstall_content(self.uuid, 'package_group', groups)
    rescue => e
      Rails.logger.error "Failed to schedule package group uninstall for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_consumer_errata(errata_ids)
      Rails.logger.debug "Scheduling errata install for consumer #{self.name}"
      Katello.pulp_server.extensions.consumer.install_content(self.uuid, 'erratum', errata_ids, {"importkeys" => true})
    rescue => e
      Rails.logger.error "Failed to schedule errata install for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def activate_pulp_node
      Katello.pulp_server.extensions.consumer.activate_node(self.uuid, 'mirror')
    end

    def deactivate_pulp_node
      Katello.pulp_server.extensions.consumer.deactivate_node(self.uuid)
    end

    def save_pulp_orchestration
      return true if self.is_a? Hypervisor
      case orchestration_for
      when :create
        pre_queue.create(:name => "create pulp consumer: #{self.name}", :priority => 3, :action => [self, :set_pulp_consumer])
      when :update
        pre_queue.create(:name => "update pulp consumer: #{self.name}", :priority => 3, :action => [self, :update_pulp_consumer])
      end
    end

    private

    def fetch_package_profile
      Katello.pulp_server.extensions.consumer.retrieve_profile(uuid, 'rpm')
    rescue RestClient::ResourceNotFound => e
      Rails.logger.error "Failed to find profile for #{uuid}: #{e}, #{e.backtrace.join("\n")}"
      {:profile => []}.with_indifferent_access
    end

  end
end
