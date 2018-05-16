require 'proxy_api'
require 'proxy_api/pulp'
require 'proxy_api/pulp_node'
module Katello
  module Concerns
    module SmartProxyExtensions
      extend ActiveSupport::Concern

      module Overrides
        def refresh
          errors = super
          update_puppet_path
          errors
        end
      end

      PULP_FEATURE = "Pulp".freeze
      PULP_NODE_FEATURE = "Pulp Node".freeze

      DOWNLOAD_INHERIT = 'inherit'.freeze
      DOWNLOAD_POLICIES = ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES + [DOWNLOAD_INHERIT]

      included do
        include ForemanTasks::Concerns::ActionSubject
        include LazyAccessor

        prepend Overrides

        before_create :associate_organizations
        before_create :associate_default_locations
        before_create :associate_lifecycle_environments
        before_validation :set_default_download_policy

        lazy_accessor :pulp_repositories, :initializer => lambda { |_s| pulp_node.extensions.repository.retrieve_all }

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

        has_many :content_facets, :class_name => "::Katello::Host::ContentFacet", :foreign_key => :content_source_id,
                                  :inverse_of => :content_source, :dependent => :nullify

        has_many :hostgroups, :class_name => "::Hostgroup", :foreign_key => :content_source_id,
                              :inverse_of => :content_source, :dependent => :nullify

        validates :download_policy, inclusion: {
          :in => DOWNLOAD_POLICIES,
          :message => _("must be one of the following: %s") % DOWNLOAD_POLICIES.join(', ')
        }
        scope :with_content, -> { with_features(PULP_FEATURE, PULP_NODE_FEATURE) }

        def self.default_capsule
          unscoped.with_features(PULP_FEATURE).first
        end

        def self.default_capsule!
          capsule = default_capsule
          fail _("Could not find a smart proxy with pulp feature.") if capsule.nil?
          capsule
        end
      end

      def puppet_path
        self[:puppet_path] || update_puppet_path
      end

      def update_puppet_path
        if has_feature?(PULP_FEATURE)
          path = ProxyAPI::Pulp.new(:url => self.url).capsule_puppet_path['puppet_content_dir']
        elsif has_feature?(PULP_NODE_FEATURE)
          path = ProxyAPI::PulpNode.new(:url => self.url).capsule_puppet_path['puppet_content_dir']
        end
        self.update_attribute(:puppet_path, path || '') if persisted?
        path
      end

      def pulp_node
        @pulp_node ||= Katello::Pulp::Server.config(pulp_url, User.remote_user)
      end

      def pulp_url
        uri = URI.parse(url)
        "#{uri.scheme}://#{uri.host}/pulp/api/v2/"
      end

      def default_capsule?
        # use map instead of pluck in case the features aren't saved yet during create
        self.features.map(&:name).include?(PULP_FEATURE)
      end

      def associate_organizations
        self.organizations = Organization.all if self.default_capsule?
      end

      def associate_default_locations
        return unless default_capsule?
        ['puppet_content', 'subscribed_hosts'].each do |type|
          default_location = ::Location.unscoped.find_by_title(
            ::Setting[:"default_location_#{type}"])
          if default_location.present? && !locations.include?(default_location)
            self.locations << default_location
          end
        end
      end

      def set_default_download_policy
        self.download_policy ||= ::Setting[:default_proxy_download_policy] || ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND
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
