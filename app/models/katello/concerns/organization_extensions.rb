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
  module Concerns
    module OrganizationExtensions
      extend ActiveSupport::Concern

      included do

        ALLOWED_DEFAULT_INFO_TYPES = %w(system distributor)

        include ForemanTasks::Concerns::ActionSubject
        include Glue::Candlepin::Owner if Katello.config.use_cp
        include Glue if Katello.config.use_cp

        include Glue::Event

        def create_event
          Headpin::Actions::OrgCreate
        end

        def destroy_event
          Headpin::Actions::OrgDestroy
        end

        include AsyncOrchestration
        include Ext::PermissionTagCleanup

        include Katello::Authorization::Organization
        include Glue::ElasticSearch::Organization if Katello.config.use_elasticsearch

        include Ext::LabelFromName

        has_many :activation_keys, :class_name => "Katello::ActivationKey", :dependent => :destroy
        has_many :providers, :class_name => "Katello::Provider", :dependent => :destroy
        has_many :products, :class_name => "Katello::Product", :through => :providers
        has_many :environments, :class_name => "Katello::KTEnvironment", :dependent => :destroy, :inverse_of => :organization
        has_one :library, :class_name => "Katello::KTEnvironment", :conditions => {:library => true}, :dependent => :destroy
        has_many :gpg_keys, :class_name => "Katello::GpgKey", :dependent => :destroy, :inverse_of => :organization
        has_many :permissions, :class_name => "Katello::Permission", :dependent => :destroy, :inverse_of => :organization
        has_many :sync_plans, :class_name => "Katello::SyncPlan", :dependent => :destroy, :inverse_of => :organization
        has_many :system_groups, :class_name => "Katello::SystemGroup", :dependent => :destroy, :inverse_of => :organization
        has_many :content_view_definitions, :class_name => "Katello::ContentViewDefinitionBase", :dependent => :destroy
        has_many :content_views, :class_name => "Katello::ContentView", :dependent => :destroy
        has_many :task_statuses, :class_name => "Katello::TaskStatus", :dependent => :destroy, :as => :task_owner

        #older association
        has_many :org_tasks, :dependent => :destroy, :class_name => "Katello::TaskStatus", :inverse_of => :organization

        has_many :notices, :class_name => "Katello::Notice", :dependent => :destroy

        serialize :default_info, Hash

        attr_accessor :statistics

        scope :having_name_or_label, lambda { |name_or_label| { :conditions => ["name = :id or label = :id", {:id => name_or_label}] } }

        before_create :create_library
        before_create :create_redhat_provider
        after_initialize :initialize_default_info

        validates :name, :uniqueness => true, :presence => true
        validates_with Validators::KatelloNameFormatValidator, :attributes => :name
        validates :label, :uniqueness => { :message => _("already exists (including organizations being deleted)") },
                  :presence => true
        validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
        validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
        validate :unique_name_and_label
        validates_with Validators::DefaultInfoValidator, :attributes => :default_info

        # Ensure that the name and label namespaces do not overlap
        def unique_name_and_label
          if new_record? && Organization.where("name = ? OR label = ?", label, name).any?
            errors.add(:organization, _("Names and labels must be unique across all organizations"))
          elsif label_changed? && Organization.where("id != ? AND name = ?", id, label).any?
            errors.add(:label, _("Names and labels must be unique across all organizations"))
          elsif name_changed? && Organization.where("id != ? AND label = ?", id, name).any?
            errors.add(:name, _("Names and labels must be unique across all organizations"))
          else
            true
          end
        end

        # Organizations which are being deleted (or deletion failed) can be filtered out with this scope.
        def self.without_deleting
          self.where(:deletion_task_id => nil)
        end

        def default_content_view
          ContentView.default.where(:organization_id => self.id).first
        end

        def systems
          System.where(:environment_id => environments)
        end

        def distributors
          Distributor.where(:environment_id => environments)
        end

        def promotion_paths
          #I'm sure there's a better way to do this
          self.environments.joins(:priors).where("prior_id = #{self.library.id}").order(:name).collect do |env|
            env.path
          end
        end

        def redhat_provider
          self.providers.redhat.first
        end

        def repo_discovery_task
          self.task_statuses.where(:task_type => :repo_discovery).order('created_at DESC').first
        end

        def create_library
          self.library = Katello::KTEnvironment.new(:name => "Library", :label => "Library", :library => true, :organization => self)
        end

        def create_redhat_provider
          self.providers << Katello::Provider.new(:name => "Red Hat", :provider_type => Katello::Provider::REDHAT, :organization => self)
        end

        def validate_destroy(current_org)
          def_error = _("Could not delete organization '%s'.")  % [self.name]
          if (current_org == self)
            [def_error, _("The current organization cannot be deleted. Please switch to a different organization before deleting.")]
          elsif (Organization.count == 1)
            [def_error, _("At least one organization must exist.")]
          end
        end

        def discover_repos(url, notify = false)
          fail _("Repository Discovery already in progress") if self.repo_discovery_task && !self.repo_discovery_task.finished?
          fail _("Discovery URL not set.") if url.blank?
          task = self.async(:organization => self, :task_type => :repo_discovery).start_discovery_task(url, notify)
          task.parameters = {:url => url}
          self.task_statuses << task
          self.save!
          task
        end

        def being_deleted?
          !self.deletion_task_id.nil?
        end

        def applying_default_info?
          return false if self.apply_info_task_id.nil?
          !TaskStatus.find_by_id(self.apply_info_task_id).finished?
        end

        def initialize_default_info
          self.default_info ||= {}

          ALLOWED_DEFAULT_INFO_TYPES.each do |key|
            if self.default_info.class == ActiveRecord::AttributeMethods::Serialization::Attribute
              self.default_info = self.default_info.unserialized_value
              if !self.default_info.value.include?(key) || self.default_info.value.class != Array
                self.default_info.value[key] = []
              end
            elsif self.default_info[key].class != Array
              self.default_info[key] = []
            end
          end
        end

        def default_info_hash
          self.default_info.is_a?(Hash) ? self.default_info : self.default_info.unserialized_value
        end

        def self.check_informable_type!(informable_type, options = {})
          defaults = {
              :message => _("Informable Type must be one of the following [ %{list} ]") %
                  { :list => ALLOWED_DEFAULT_INFO_TYPES.join(", ") },
              :error => RuntimeError
          }
          options = defaults.merge(options)

          unless ALLOWED_DEFAULT_INFO_TYPES.include?(informable_type)
            fail options[:error], options[:message]
          end
        end

        def apply_default_info(informable_type, custom_info, options = {})
          options = {:async => true}.merge(options)
          Organization.check_informable_type!(informable_type)
          objects = self.send(informable_type.pluralize)
          ids_and_types = objects.inject([]) do |collection, obj|
            collection << { :informable_type => obj.class.name, :informable_id => obj.id }
          end

          if options[:async]
            task = self.async(:organization => self, :task_type => "apply default info").run_apply_info(ids_and_types, custom_info)
            self.apply_info_task_id = task.id
            self.save!
            return task
          else
            return CustomInfo.apply_to_set(ids_and_types, custom_info)
          end
        end

        def run_apply_info(ids_and_types, custom_info)
          CustomInfo.apply_to_set(ids_and_types, custom_info)
        end

        def auto_attaching_all_systems?
          return false if self.owner_auto_attach_all_systems_task_id.nil?
          !TaskStatus.find_by_id(self.owner_auto_attach_all_systems_task_id).finished?
        end

        def auto_attach_all_systems
          job = self.owner_auto_attach
          task = self.async(:organization => self, :task_type => "monitor owner all_systems auto_attach").monitor_owner_auto_attach(job)
          self.owner_auto_attach_all_systems_task_id = task.id
          self.save!
          return task
        end

        def monitor_owner_auto_attach(job, options = {})
          options = { :pause => 5 }.merge(options)
          loop do
            break unless Resources::Candlepin::Job.not_finished?(Resources::Candlepin::Job.get(job["id"]))
            sleep options[:pause]
          end
          return job["id"]
        end

        def syncable_content?
          products.any?(&:syncable_content?)
        end

      private

        def start_discovery_task(url, notify = false)
          task_id = AsyncOperation.current_task_id
          task = TaskStatus.find(task_id)
          task.parameters = {:url => url}
          task.result ||= []
          task.save!

          #Lambda to continually update the task
          found_func = lambda do |found_url|
            task = TaskStatus.find(task_id)
            task.result << found_url
            task.save!
          end

          #Lambda to decide to continue or not
          #  Using the saved task_id to compare current providers
          #  task id
          continue_func = lambda do
            task = TaskStatus.find(task_id)
            !task.canceled?
          end

          discover = RepoDiscovery.new(url)
          discover.run(found_func, continue_func)
        rescue => e
          Notify.exception _('Repos discovery failed.'), e if notify
          raise e
        end
      end
    end
  end
end
