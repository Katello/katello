# rubocop:disable AccessModifierIndentation
module Katello
  module Concerns
    module SmartProxyExtensions
      extend ActiveSupport::Concern

      PULP_FEATURE = "Pulp"
      PULP_NODE_FEATURE = "Pulp Node"

      included do
        before_create :associate_organizations
        before_create :associate_default_location
        before_create :associate_lifecycle_environments
        attr_accessible :lifecycle_environment_ids

        alias_method_chain :refresh, :dynflow

        has_many :containers,
                 :class_name => "Container",
                 :foreign_key => :capsule_id,
                 :inverse_of => :capsule,
                 :dependent => :nullify

        has_many :capsule_lifecycle_environments,
                 :class_name  => "Katello::CapsuleLifecycleEnvironment",
                 :foreign_key => :capsule_id,
                 :dependent   => :destroy,
                 :inverse_of => :capsule

        has_many :lifecycle_environments,
                 :class_name => "Katello::KTEnvironment",
                 :through    => :capsule_lifecycle_environments,
                 :source     => :lifecycle_environment

        has_many :hosts,      :class_name => "::Host::Managed", :foreign_key => :content_source_id,
                              :inverse_of => :content_source
        has_many :hostgroups, :class_name => "::Hostgroup",     :foreign_key => :content_source_id,
                              :inverse_of => :content_source

        scope :with_content, with_features(PULP_FEATURE, PULP_NODE_FEATURE)

        def self.default_capsule
          with_features(PULP_FEATURE).first
        end
      end

      def default_capsule?
        # use map instead of pluck in case the features aren't saved yet during create
        self.features.map(&:name).include?(PULP_FEATURE)
      end

      def associate_organizations
        self.organizations = Organization.all if self.default_capsule?
      end

      def associate_default_location
        if self.default_capsule?
          default_location = Location.default_location
          if default_location && !self.locations.include?(default_location)
            self.locations << default_location
          end
        end
      end

      def refresh_with_dynflow
        old_features = self.features.all
        errors = refresh_without_dynflow
        ::ForemanTasks.sync_task(::Actions::Katello::CapsuleContent::FeaturesRefreshed, self, old_features, self.features)
        errors
      rescue Katello::Errors::CapsuleContentMissingConsumer => e
        errors.add(:base, e.message)
        errors
      end

      def associate_lifecycle_environments
        self.lifecycle_environments = Katello::KTEnvironment.all if self.default_capsule?
      end
    end
  end
end

class ::SmartProxy::Jail < Safemode::Jail
  allow :hostname
end
