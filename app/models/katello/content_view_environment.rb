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

    has_many :hostgroup_content_facets, :class_name => "Katello::Hostgroup::ContentFacet", :dependent => :nullify, :inverse_of => :content_view_environment
    has_many :hostgroups, through: :hostgroup_content_facets, :class_name => "::Hostgroup"

    has_many :content_view_environment_activation_keys, :class_name => "Katello::ContentViewEnvironmentActivationKey", :dependent => :destroy, :inverse_of => :content_view_environment
    has_many :activation_keys, through: :content_view_environment_activation_keys, :class_name => "::Katello::ActivationKey", :inverse_of => :content_view_environments

    validates_lengths_from_database
    validates :environment_id, uniqueness: {scope: :content_view_id}, presence: true
    validates :content_view_id, presence: true
    validates :content_view_version_id, presence: true
    validates_with Validators::ContentViewEnvironmentOrgValidator
    validates_with Validators::ContentViewEnvironmentCoherentDefaultValidator

    before_save :generate_info

    scope :non_default, -> { joins(:content_view).where("katello_content_views.default" => false) }
    scope :default, -> { joins(:content_view).where("katello_content_views.default" => true) }
    scope :non_generated, -> { where(content_view: ::Katello::ContentView.ignore_generated) }

    scoped_search :on => :id, :complete_value => true
    scoped_search :on => :label, :complete_value => true
    scoped_search :relation => :content_view, :on => :label, :rename => :content_view
    scoped_search :relation => :lifecycle_environment, :on => :label, :rename => :lifecycle_environment

    alias :lifecycle_environment :environment
    has_one :organization, :through => :environment

    def self.in_organization(org)
      where(environment_id: org.kt_environments)
    end

    def self.for_content_facets(content_facets)
      joins(:content_facets).
        where("#{Katello::ContentViewEnvironmentContentFacet.table_name}.content_facet_id" => content_facets).distinct
    end

    def self.with_label_and_org(label, organization: Organization.current)
      joins(:environment, :content_view).where("#{Katello::KTEnvironment.table_name}.organization_id" => organization, label: label).first
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

    def priority(content_object)
      case content_object
      when Katello::ActivationKey
        content_view_environment_activation_keys.find_by(:activation_key_id => content_object.id).try(:priority)
      when Katello::Host::ContentFacet
        content_view_environment_content_facets.find_by(:content_facet_id => content_object.id).try(:priority)
      end
    end

    def self.find_by_cv_and_lce!(content_view_id, lifecycle_environment_id)
      cve = find_by(content_view_id: content_view_id, environment_id: lifecycle_environment_id)
      return cve if cve

      env_label = Katello::KTEnvironment.find_by(id: lifecycle_environment_id)&.label
      fail Katello::Errors::ContentViewEnvironmentError,
        _("Unable to find a lifecycle environment with ID %s") % lifecycle_environment_id if env_label.nil?
      cv_label = Katello::ContentView.find_by(id: content_view_id)&.label
      fail Katello::Errors::ContentViewEnvironmentError,
        _("Unable to find a content view with ID %s") % content_view_id if cv_label.nil?
      fail Katello::Errors::ContentViewEnvironmentError,
        _("Cannot assign content view environment %s/%s: The content view has either not been published or has not been promoted to that lifecycle environment.") % [env_label, cv_label]
    end

    def self.fetch_content_view_environments(organization:, labels: [], ids: [])
      # Must ensure CVEs remain in the same order.
      # Using ActiveRecord .where will return them in a different order.
      id_errors = []
      label_errors = []
      cves = []
      if ids.present?
        ids.each do |id|
          cve = ::Katello::ContentViewEnvironment.find_by(id: id)
          if cve.blank?
            id_errors << id
          else
            cves << cve
          end
        end
      elsif labels.present?
        environment_names = labels.map(&:strip)
        environment_names.each do |name|
          cve = with_label_and_org(name, organization: organization)
          if cve.blank?
            label_errors << name
          else
            cves << cve
          end
        end
      end
      if labels.present? && labels.length != cves.length
        fail HttpErrors::UnprocessableEntity, _("No content view environments found with names: %{names}") % {names: label_errors.join(', ')} if label_errors.present?
      elsif ids.present? && ids.length != cves.length
        fail HttpErrors::UnprocessableEntity, _("No content view environments found with ids: %{ids}") % {ids: id_errors.join(', ')} if id_errors.present?
      end
      cves
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
