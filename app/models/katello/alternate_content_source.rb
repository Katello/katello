module Katello
  class AlternateContentSource < Katello::Model
    audited

    include Ext::LabelFromName
    include Encryptable
    include ::ScopedSearchExtensions
    include Authorization::AlternateContentSource
    include ForemanTasks::Concerns::ActionSubject

    self.table_name = :katello_alternate_content_sources

    ACS_TYPES = %w(custom simplified rhui).freeze
    CONTENT_TYPES = [::Katello::Repository::YUM_TYPE, ::Katello::Repository::FILE_TYPE].freeze
    AUDIT_REFRESH_ACTION = 'refresh'.freeze

    encrypts :upstream_password

    belongs_to :ssl_ca_cert, inverse_of: :ssl_ca_alternate_content_sources, class_name: "Katello::ContentCredential"
    belongs_to :ssl_client_cert, inverse_of: :ssl_client_alternate_content_sources, class_name: "Katello::ContentCredential"
    belongs_to :ssl_client_key, inverse_of: :ssl_key_alternate_content_sources, class_name: "Katello::ContentCredential"

    has_many :alternate_content_source_products, dependent: :delete_all, inverse_of: :alternate_content_source,
             class_name: "Katello::AlternateContentSourceProduct"
    has_many :products, through: :alternate_content_source_products, inverse_of: :alternate_content_sources,
             class_name: "Katello::Product"

    has_many :smart_proxy_alternate_content_sources, dependent: :delete_all,
             inverse_of: :alternate_content_source
    has_many :smart_proxies, -> { distinct }, through: :smart_proxy_alternate_content_sources

    validates :base_url, :subpaths, :verify_ssl, :upstream_username,
              :upstream_password, :ssl_ca_cert, :ssl_client_cert, :ssl_client_key, if: :simplified?, absence: true
    validates :base_url, if: -> { custom? || rhui? }, presence: true
    validates :products, if: -> { custom? || rhui? }, absence: true
    validates :label, :uniqueness => true
    validates :name, :uniqueness => true, presence: true
    # verify ssl must be validated this way due to presence: <bool> failing on a value of false
    validates :verify_ssl, if: -> { custom? || rhui? }, inclusion: {
      in: [true, false],
      message: "can't be blank"
    }
    validates :verify_ssl, if: :custom?, exclusion: [nil]
    validates :alternate_content_source_type, inclusion: {
      in: ->(_) { ACS_TYPES },
      allow_blank: false,
      message: ->(_, _) { _("is not a valid type. Must be one of the following: %s") % ACS_TYPES.join(',') }
    }
    validates :content_type, inclusion: {
      in: ->(_) { RepositoryTypeManager.defined_repository_types.keys & CONTENT_TYPES },
      allow_blank: false,
      message: ->(_, _) { _("is not allowed for ACS. Must be one of the following: %s") % (RepositoryTypeManager.defined_repository_types.keys & CONTENT_TYPES).join(',') }
    }
    validates :content_type, if: -> { rhui? }, inclusion: {
      in: [::Katello::Repository::YUM_TYPE],
      message: "'%{value}' is not valid for RHUI ACS"
    }

    validate :constraint_acs_update, on: :update
    validates_with Validators::AlternateContentSourcePathValidator, :attributes => [:base_url, :subpaths], :if => :custom?

    scope :uses_http_proxies, -> { where(use_http_proxies: true) }

    scoped_search on: :name, complete_value: true
    scoped_search on: :label, complete_value: true
    scoped_search on: :description, complete_value: true
    scoped_search on: :base_url, complete_value: true
    scoped_search on: :subpath, ext_method: :search_by_subpath
    scoped_search on: :content_type, complete_value: true
    scoped_search on: :alternate_content_source_type, complete_value: true
    scoped_search on: :upstream_username, complete_value: true
    scoped_search on: :id, relation: :smart_proxies, rename: :smart_proxy_id, validator: ScopedSearch::Validators::INTEGER, only_explicit: true
    scoped_search on: :name, relation: :smart_proxies, rename: :smart_proxy_name, complete_value: true
    scoped_search on: :id, relation: :products, rename: :product_id, validator: ScopedSearch::Validators::INTEGER, only_explicit: true
    scoped_search on: :name, relation: :products, rename: :product_name, complete_value: true

    def backend_service(smart_proxy, repository = nil)
      @service ||= ::Katello::Pulp3::AlternateContentSource.new(self, smart_proxy, repository)
    end

    def custom?
      alternate_content_source_type == 'custom'
    end

    def simplified?
      alternate_content_source_type == 'simplified'
    end

    def rhui?
      alternate_content_source_type == 'rhui'
    end

    def self.with_products(products)
      products = [products] unless products.is_a?(Array)
      joins(:alternate_content_source_products).where('katello_alternate_content_source_products.product_id in (:product_ids)', product_ids: products.pluck(:id))
    end

    def self.with_type(content_type)
      where(content_type: content_type)
    end

    def self.search_by_subpath(_key, operator, value)
      conditions = sanitize_sql_for_conditions(["? #{operator} ANY (subpaths)", value_to_sql(operator, value)])
      { conditions: conditions }
    end

    def latest_dynflow_refresh_task
      @latest_dynflow_refresh_task ||= ForemanTasks::Task::DynflowTask.where(:label => Actions::Katello::AlternateContentSource::Refresh.name).
          for_resource(self).order(:started_at).last
    end

    def audit_refresh
      write_audit(action: AUDIT_REFRESH_ACTION, comment: _('Successfully refreshed.'), audited_changes: {})
    end

    def audit_updated_products(old_product_ids)
      write_audit(action: 'update', comment: _('Products updated.'), audited_changes: { 'product_ids' => [old_product_ids, product_ids] })
    end

    def self.humanize_class_name(_name = nil)
      "Alternate Content Sources"
    end

    # Disallow static properties from being modified on update
    def constraint_acs_update
      if changes.keys.include? "content_type"
        errors.add(:content_type, "cannot be modified once an ACS is created")
      end
      if changes.keys.include? "alternate_content_source_type"
        errors.add(:alternate_content_source_type, "cannot be modified once an ACS is created")
      end
    end
  end
end
