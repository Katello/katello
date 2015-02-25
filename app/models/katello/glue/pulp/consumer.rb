#
# Copyright 2014 Red Hat, Inc.
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
  module Glue::Pulp::Consumer
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :include, LazyAccessor

      base.class_eval do
        lazy_accessor :pulp_facts, :initializer => lambda { |_s| Katello.pulp_server.extensions.consumer.retrieve(uuid) }
        lazy_accessor :package_profile, :initializer => lambda { |_s| fetch_package_profile }
        lazy_accessor :simple_packages, :initializer => (lambda do |_s|
                                                           fetch_package_profile["profile"].
                                                             collect { |package| Glue::Pulp::SimplePackage.new(package) }
                                                         end)
      end
    end

    module InstanceMethods
      def bound_node_repos
        bindings(Runcible::Models::NodesHttpDistributor.type_id)
      end

      def bindings(type_id)
        bindings = Katello.pulp_server.extensions.consumer.retrieve_bindings(uuid)
        bindings.select { |b| b['type_id'] == type_id }.collect { |repo| repo["repo_id"] }
      end

      def enable_node_repos(repo_ids)
        enable_repos(Runcible::Models::NodesHttpDistributor.type_id, bound_node_repos, repo_ids,
                     :notify_agent => false, :binding_config => {:strategy => 'mirror'})
      end

      def pulp_bound_yum_repositories
        bindings(Runcible::Models::YumDistributor.type_id)
      end

      def propagate_yum_repos
        pulp_ids = self.bound_repositories.map { |repo| repo.library_instance.try(:pulp_id) || repo.pulp_id }
        enable_repos(Runcible::Models::YumDistributor.type_id, pulp_bound_yum_repositories, pulp_ids, :notify_agent => false)
      end

      # Binds and unbinds distributors of a certain type across repos
      def enable_repos(distributor_type, existing_ids, update_ids, bind_options = {})
        # calculate repoids to bind/unbind
        bound_ids     = existing_ids
        intersection  = update_ids & bound_ids
        bind_ids      = update_ids - intersection
        unbind_ids    = bound_ids - intersection

        Rails.logger.debug "Bound repo ids: #{bound_ids.inspect}"
        Rails.logger.debug "Update repo ids: #{update_ids.inspect}"
        Rails.logger.debug "Repo ids to bind: #{bind_ids.inspect}"
        Rails.logger.debug "Repo ids to unbind: #{unbind_ids.inspect}"

        error_ids = unbind_repo_ids(unbind_ids, distributor_type)
        error_ids += bind_repo_ids(bind_ids, distributor_type, bind_options)
        error_ids
      end

      def unbind_repo_ids(repo_ids, distributor_type)
        error_ids     = []

        repo_ids.each do |repo_id|
          begin
            Katello.pulp_server.extensions.consumer.unbind_all(uuid,  repo_id, distributor_type)
          rescue => e
            Rails.logger.error "Failed to unbind repo #{repo_id}: #{e}, #{e.backtrace.join("\n")}"
            error_ids << repo_id
          end
        end
        error_ids
      end

      def bind_repo_ids(repo_ids, distributor_type, bind_options)
        error_ids     = []

        repo_ids.each do |repo_id|
          begin
            Katello.pulp_server.extensions.consumer.bind_all(uuid, repo_id, distributor_type, bind_options)
          rescue => e
            Rails.logger.error "Failed to bind repo #{repo_id}: #{e}, #{e.backtrace.join("\n")}"
            error_ids << repo_id
          end
        end
        error_ids
      end

      def errata_ids
        response = Katello.pulp_server.extensions.consumer.applicable_errata([self.uuid])
        return [] if response.empty?
        response[0]['applicability']['erratum'] || []
      end

      def import_applicability
        applicable_errata_ids = ::Katello::Erratum.where(:uuid => errata_ids).pluck(:id)
        ActiveRecord::Base.transaction do
          Katello::SystemErratum.where(:system_id => self.id).delete_all
          unless applicable_errata_ids.empty?
            inserts = applicable_errata_ids.map { |erratum_id| "(#{erratum_id.to_i}, #{id.to_i})" }
            sql = "INSERT INTO katello_system_errata (erratum_id, system_id) VALUES #{inserts.join(', ')}"
            ActiveRecord::Base.connection.execute(sql)
          end
        end
      end

      def generate_applicability
        old_user = User.current
        User.current = User.anonymous_admin
        ForemanTasks.async_task(::Actions::Katello::System::GenerateApplicability, [self])
      ensure
        User.current = old_user
      end

      def del_pulp_consumer
        Rails.logger.debug "Deleting consumer in pulp: #{self.name}"
        Katello.pulp_server.extensions.consumer.delete(self.uuid)
      rescue => e
        Rails.logger.error "Failed to delete pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
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
        self.generate_applicability
      rescue => e
        Rails.logger.error "Failed to upload package profile to pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def install_package(packages)
        Rails.logger.debug "Scheduling package install for consumer #{self.name}"
        Katello.pulp_server.extensions.consumer.install_content(self.uuid, 'rpm', packages, "importkeys" => true)
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

      def install_package_group(groups)
        Rails.logger.debug "Scheduling package group install for consumer #{self.name}"
        Katello.pulp_server.extensions.consumer.install_content(self.uuid, 'package_group', groups, "importkeys" => true)
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
        Katello.pulp_server.extensions.consumer.install_content(self.uuid, 'erratum', errata_ids, "importkeys" => true)
      rescue => e
        Rails.logger.error "Failed to schedule errata install for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def katello_agent_installed?
        return false if self.is_a? Hypervisor
        simple_packages.any? { |package| package.name == "katello-agent" }
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
end
