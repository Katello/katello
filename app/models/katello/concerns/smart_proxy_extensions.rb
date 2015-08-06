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
        before_create :associate_content_host

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

        belongs_to :content_host,
                   :class_name => "Katello::System",
                   :inverse_of => :capsule,
                   :foreign_key => :content_host_id

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

      def associate_lifecycle_environments
        self.lifecycle_environments = Katello::KTEnvironment.all if self.default_capsule?
      end

      def associate_content_host
        content_host = Katello::System.where(:name => self.name).order("created_at DESC").first
        self.content_host = content_host if content_host
      end
    end
  end
end

class ::SmartProxy::Jail < Safemode::Jail
  allow :hostname
end
