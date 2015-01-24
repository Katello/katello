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
  module Concerns
    module OrganizationExtensions
      extend ActiveSupport::Concern

      included do
        ALLOWED_DEFAULT_INFO_TYPES = %w(system distributor)

        include ForemanTasks::Concerns::ActionSubject
        include ForemanTasks::Concerns::ActionTriggering
        include Glue::Candlepin::Owner if Katello.config.use_cp
        include Glue if Katello.config.use_cp

        include Katello::Authorization::Organization
        include Ext::LabelFromName

        has_many :activation_keys, :class_name => "Katello::ActivationKey", :dependent => :destroy
        has_many :providers, :class_name => "Katello::Provider", :dependent => :destroy
        has_many :products, :class_name => "Katello::Product", :dependent => :destroy, :inverse_of => :organization
        # has_many :environments is already defined in Foreman taxonomy.rb
        has_many :kt_environments, :class_name => "Katello::KTEnvironment", :dependent => :restrict, :inverse_of => :organization
        has_one :library, :class_name => "Katello::KTEnvironment", :conditions => {:library => true}, :dependent => :destroy
        has_many :gpg_keys, :class_name => "Katello::GpgKey", :dependent => :destroy, :inverse_of => :organization
        has_many :sync_plans, :class_name => "Katello::SyncPlan", :dependent => :destroy, :inverse_of => :organization
        has_many :host_collections, :class_name => "Katello::HostCollection", :dependent => :destroy, :inverse_of => :organization
        has_many :content_views, :class_name => "Katello::ContentView", :dependent => :destroy, :inverse_of => :organization
        has_many :content_view_environments, :through => :content_views
        has_many :task_statuses, :class_name => "Katello::TaskStatus", :dependent => :destroy, :as => :task_owner

        #older association
        has_many :org_tasks, :dependent => :destroy, :class_name => "Katello::TaskStatus", :inverse_of => :organization

        has_many :notices, :class_name => "Katello::Notice", :dependent => :destroy

        serialize :default_info, Hash

        attr_accessor :statistics

        scope :having_name_or_label, lambda { |name_or_label| { :conditions => ["name = :id or label = :id", {:id => name_or_label}] } }
        scoped_search :on => :label, :complete_value => :true

        after_initialize :initialize_default_info
        after_create :associate_default_capsule

        validates :name, :uniqueness => true, :presence => true
        validates_with Validators::KatelloNameFormatValidator, :attributes => :name
        validates :label, :presence => true
        validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
        validate :unique_name_and_label
        validates_with Validators::DefaultInfoValidator, :attributes => :default_info

        # Ensure that the name and label namespaces do not overlap
        def unique_name_and_label
          if new_record? && Organization.where("name = ? OR label = ?", name, label).any?
            errors.add(:organization, _("Names and labels must be unique across all organizations"))
          elsif label_changed? && Organization.where("id != ? AND label = ?", id, label).any?
            errors.add(:label, _("Names and labels must be unique across all organizations"))
          elsif name_changed? && Organization.where("id != ? AND name = ?", id, name).any?
            errors.add(:name, _("Names and labels must be unique across all organizations"))
          else
            true
          end
        end

        def default_content_view
          ContentView.default.where(:organization_id => self.id).first
        end

        def systems
          System.where(:environment_id => kt_environments)
        end

        def distributors
          Distributor.where(:environment_id => kt_environments)
        end

        def promotion_paths
          #I'm sure there's a better way to do this
          self.kt_environments.joins(:priors).where("prior_id = #{self.library.id}").order(:name).collect do |env|
            env.path
          end
        end

        def redhat_provider
          self.providers.redhat.first
        end

        def anonymous_provider
          self.providers.anonymous.first
        end

        def manifest_history
          imports.map { |i| OpenStruct.new(i) }
        end

        def repo_discovery_task
          self.task_statuses.where(:task_type => :repo_discovery).order('created_at DESC').first
        end

        def create_library
          self.library = Katello::KTEnvironment.new(:name => "Library", :label => "Library", :library => true, :organization => self)
        end

        def create_redhat_provider
          self.providers << Katello::Provider.new(:name => "Red Hat", :provider_type => Katello::Provider::REDHAT)
        end

        def associate_default_capsule
          capsule_content = Katello::CapsuleContent.default_capsule
          capsule_content.capsule.organizations << self if capsule_content
        end

        def create_anonymous_provider
          self.providers << Katello::Provider.new(:name => Katello::Provider::ANONYMOUS, :provider_type => Katello::Provider::ANONYMOUS)
        end

        def validate_destroy(current_org)
          def_error = _("Could not delete organization '%s'.")  % [self.name]
          if (current_org == self)
            [def_error, _("The current organization cannot be deleted. Please switch to a different organization before deleting.")]
          elsif (Organization.count == 1)
            [def_error, _("At least one organization must exist.")]
          end
        end

        def redhat_repository_url
          redhat_provider.repository_url
        end

        def redhat_docker_registry_url
          redhat_provider.docker_registry_url
        end

        def being_deleted?
          ForemanTasks::Task::DynflowTask.for_action(::Actions::Katello::Organization::Destroy).
            for_resource(self).active.any?
        end

        def destroy!
          unless destroy
            fail self.errors.full_messages.join('; ')
          end
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

        def syncable_content?
          products.any?(&:syncable_content?)
        end

        # overwrite methods generated by ancestry gem for organization.rb
        def parent=(_parent)
          fail ::Foreman::Exception, N_("You cannot set an organization's parent. This feature is disabled.")
        end

        def parent_id=(_parent_id)
          fail ::Foreman::Exception, N_("You cannot set an organization's parent_id. This feature is disabled.")
        end
      end
    end
  end
end
