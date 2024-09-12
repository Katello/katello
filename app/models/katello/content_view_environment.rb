module Katello
  class ContentViewEnvironment < Katello::Model
    audited :associated_with => :content_view
    include ForemanTasks::Concerns::ActionSubject
    include Glue::Candlepin::Environment
    include Glue
    include Authorization::ContentViewEnvironment

    belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :content_view_environments
    belongs_to :environment, :class_name => "Katello::KTEnvironment", :inverse_of => :content_view_environments
    belongs_to :lifecycle_environment, :class_name => "Katello::KTEnvironment", :foreign_key => :environment_id, :inverse_of => :content_view_environments
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion",
               :inverse_of => :content_view_environments

    has_many :content_view_environment_content_facets, :class_name => "Katello::ContentViewEnvironmentContentFacet", :dependent => :destroy, :inverse_of => :content_view_environment
    has_many :content_facets, through: :content_view_environment_content_facets, :class_name => "::Katello::Host::ContentFacet", :inverse_of => :content_view_environments

    has_many :content_view_environment_activation_keys, :class_name => "Katello::ContentViewEnvironmentActivationKey", :dependent => :destroy, :inverse_of => :content_view_environment
    has_many :activation_keys, through: :content_view_environment_activation_keys, :class_name => "::Katello::ActivationKey", :inverse_of => :content_view_environments

    validates_lengths_from_database
    validates :environment_id, uniqueness: {scope: :content_view_id}, presence: true
    validates :content_view_id, presence: true
    validates_with Validators::ContentViewEnvironmentOrgValidator
    validates_with Validators::ContentViewEnvironmentCoherentDefaultValidator

    before_save :generate_info

    scope :non_default, -> { joins(:content_view).where("katello_content_views.default" => false) }
    scope :default, -> { joins(:content_view).where("katello_content_views.default" => true) }
    alias :lifecycle_environment :environment
    has_one :organization, :through => :environment

    def self.for_content_facets(content_facets)
      joins(:content_view_environment_content_facets, :content_facets).where("#{Katello::ContentViewEnvironmentContentFacet.table_name}.content_facet_id" => content_facets).uniq
    end

    def self.with_candlepin_name(cp_name, organization: Organization.current)
      joins(:environment, :content_view).where("#{Katello::KTEnvironment.table_name}.organization_id" => organization, label: cp_name).first
    end

    # retrieve the owning environment for this content view environment.
    def owner
      self.environment
    end

    def hosts
      ::Host.in_content_view_environment(:content_view => self.content_view, :lifecycle_environment => self.environment)
    end

    def activation_keys
      ::Katello::ActivationKey.with_content_views(self.content_view).with_environments(self.environment)
    end

    def default_environment?
      content_view.default? && environment.library?
    end

    def candlepin_name
      label
    end

    def priority(content_object)
      if content_object.is_a? Katello::ActivationKey
        content_view_environment_activation_keys.find_by(:activation_key_id => content_object.id).try(:priority)
      elsif content_object.is_a? Katello::Host::ContentFacet
        content_view_environment_content_facets.find_by(:content_facet_id => content_object.id).try(:priority)
      end
    end

    def self.fetch_content_view_environments(labels: [], ids: [], organization:)
      # Must do maps here to ensure CVEs remain in the same order.
      # Using ActiveRecord .where will return them in a different order.
      if ids.present?
        cves = ids.map do |id|
          ::Katello::ContentViewEnvironment.find_by(id: id)
        end
        cves.compact
      elsif labels.present?
        environment_names = labels.map(&:strip)
        environment_names.map! do |name|
          with_candlepin_name(name, organization: organization)
        end
        environment_names.compact
      end
    end

    private

    def generate_info
      self.name ||= environment.name

      if default_environment?
        self.label ||= environment.label
        self.cp_id ||= Katello::Util::Data.hexdigest(environment.organization.label)
      else
        self.label ||= [environment.label, content_view.label].join('/')
        self.cp_id ||= Katello::Util::Data.hexdigest([environment.id, content_view.id].join('-'))
      end
    end
  end
end
