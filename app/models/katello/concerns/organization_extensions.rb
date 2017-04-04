module Katello
  module Concerns
    module OrganizationExtensions
      extend ActiveSupport::Concern

      included do
        ALLOWED_DEFAULT_INFO_TYPES = %w(system distributor).freeze

        include ForemanTasks::Concerns::ActionSubject
        include ForemanTasks::Concerns::ActionTriggering
        include Glue::Candlepin::Owner if SETTINGS[:katello][:use_cp]
        include Glue if SETTINGS[:katello][:use_cp]

        include Katello::Authorization::Organization
        include Ext::LabelFromName

        has_many :activation_keys, :class_name => "Katello::ActivationKey", :dependent => :destroy
        has_many :providers, :class_name => "Katello::Provider", :dependent => :destroy
        has_many :products, :class_name => "Katello::Product", :dependent => :destroy, :inverse_of => :organization
        # has_many :environments is already defined in Foreman taxonomy.rb
        has_many :kt_environments, :class_name => "Katello::KTEnvironment", :dependent => :restrict_with_exception, :inverse_of => :organization
        has_one :library, lambda { where(:library => true) }, :class_name => "Katello::KTEnvironment", :dependent => :destroy
        has_many :gpg_keys, :class_name => "Katello::GpgKey", :dependent => :destroy, :inverse_of => :organization
        has_many :sync_plans, :class_name => "Katello::SyncPlan", :dependent => :destroy, :inverse_of => :organization
        has_many :host_collections, :class_name => "Katello::HostCollection", :dependent => :destroy, :inverse_of => :organization
        has_many :content_views, :class_name => "Katello::ContentView", :dependent => :destroy, :inverse_of => :organization
        has_many :content_view_environments, :through => :content_views
        has_many :task_statuses, :class_name => "Katello::TaskStatus", :dependent => :destroy, :as => :task_owner
        has_many :subscriptions, :class_name => "Katello::Subscription", :dependent => :destroy, :inverse_of => :organization

        #older association
        has_many :org_tasks, :dependent => :destroy, :class_name => "Katello::TaskStatus", :inverse_of => :organization

        attr_accessor :statistics

        scope :having_name_or_label, ->(name_or_label) { where("name = :id or label = :id", :id => name_or_label) }
        scoped_search :on => :label, :complete_value => :true

        after_create :associate_default_capsule
        validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
        validates :label, :uniqueness => true

        def default_content_view
          ContentView.default.where(:organization_id => self.id).first
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

        def active_pools_count
          self.pools.count { |p| p[:activeSubscription] == true }
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
          def_error = _("Could not delete organization '%s'.") % [self.name]
          if (current_org == self)
            [def_error, _("The current organization cannot be deleted. Please switch to a different organization before deleting.")]
          elsif (Organization.count == 1)
            [def_error, _("At least one organization must exist.")]
          end
        end

        def redhat_repository_url
          redhat_provider.repository_url
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

        def latest_repo_discovery
          ForemanTasks::Task::DynflowTask.for_action(::Actions::Katello::Repository::Discover)
            .for_resource(::User.current).order("started_at").last
        end

        def cancel_repo_discovery
          discovery = latest_repo_discovery
          if discovery
            discovery.execution_plan.steps.each_pair do |_num, step|
              if step.cancellable? && step.is_a?(Dynflow::ExecutionPlan::Steps::RunStep)
                ::ForemanTasks.dynflow.world.event(discovery.execution_plan.id, step.id, Dynflow::Action::Cancellable::Cancel)
              end
            end
          end
          discovery
        end

        def regenerate_ueber_cert
          ::Katello::Resources::Candlepin::Owner.generate_ueber_cert(self.label)
        end
      end
    end
  end
end
