module Katello
  class Provider < Katello::Model
    include ForemanTasks::Concerns::ActionSubject
    include Glue::Provider
    include Glue

    REDHAT = 'Red Hat'.encode('utf-8')
    CUSTOM = 'Custom'.encode('utf-8')
    ANONYMOUS = 'Anonymous'.encode('utf-8')
    TYPES = [REDHAT, CUSTOM, ANONYMOUS].freeze

    belongs_to :organization, :inverse_of => :providers, :class_name => "Organization"
    belongs_to :task_status, :inverse_of => :provider
    has_many :products, :class_name => "Katello::Product", :inverse_of => :provider, :dependent => :restrict_with_exception
    has_many :repositories, :through => :products

    validates_lengths_from_database
    validates :name, :uniqueness => {:scope => :organization_id}
    validates :provider_type, :inclusion => {:in => TYPES,
                                             :allow_blank => false, :message => "Please select provider type from one of the following: #{TYPES.join(', ')}."}
    validate :constraint_redhat_update
    validate :only_one_rhn_provider
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name

    before_destroy :prevent_redhat_deletion

    scope :redhat, -> { where(:provider_type => REDHAT) }
    scope :custom, -> { where(:provider_type => CUSTOM) }
    scope :anonymous, -> { where(:provider_type => ANONYMOUS) }

    def only_one_rhn_provider
      # validate only when new record is added (skip explicit valid? calls)
      if new_record? && provider_type == REDHAT && count_providers(REDHAT) != 0
        errors.add(:base, _("Only one Red Hat provider permitted for an Organization"))
      end
    end

    def prevent_redhat_deletion
      if !being_deleted? && redhat_provider?
        Rails.logger.error _("Red Hat provider can not be deleted")
        throw :abort
      else
        # organization that is being deleted via background destroyer can delete rh provider
        true
      end
    end

    def constraint_redhat_update
      if !new_record? && redhat_provider?
        allowed_changes = %w(task_status_id)
        not_allowed_changes = changes.keys - allowed_changes
        unless not_allowed_changes.empty?
          errors.add(:base, _("the following attributes can not be updated for the Red Hat provider: [ %s ]") % not_allowed_changes.join(", "))
        end
      end
    end

    def count_providers(type)
      Provider.where(:organization_id => self.organization_id, :provider_type => type).count(:id)
    end

    def yum_repo?
      provider_type == CUSTOM || provider_type == ANONYMOUS
    end

    def redhat_provider=(is_rh)
      is_rh ? REDHAT : ANONYMOUS # Anonymous is the now the default
    end

    def redhat_provider?
      provider_type == REDHAT
    end

    def custom_provider?
      provider_type == CUSTOM
    end

    def anonymous_provider?
      provider_type == ANONYMOUS
    end

    delegate :being_deleted?, to: :organization

    def serializable_hash(options = {})
      options = {} if options.nil?
      hash = super(options)
      hash.merge(:sync_state => self.sync_state,
                        :last_sync => self.last_sync)
    end

    def manifest_task
      return task_status
    end

    def as_json(*args)
      super.merge('organization_label' => self.organization.label)
    end

    def total_products
      products.length
    end

    def total_repositories
      repositories.length
    end

    def related_resources
      self.organization
    end
  end
end
