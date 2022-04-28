module Katello
  class AlternateContentSource < Katello::Model
    include Ext::LabelFromName
    include Encryptable
    include ::ScopedSearchExtensions
    include Authorization::AlternateContentSource
    include ForemanTasks::Concerns::ActionSubject

    self.table_name = :katello_alternate_content_sources

    # TODO: simplified, rhui
    ACS_TYPES = %w(custom).freeze
    CONTENT_TYPES = [::Katello::Repository::YUM_TYPE, ::Katello::Repository::FILE_TYPE].freeze

    encrypts :upstream_password

    belongs_to :ssl_ca_cert, inverse_of: :ssl_ca_alternate_content_sources, class_name: "Katello::ContentCredential"
    belongs_to :ssl_client_cert, inverse_of: :ssl_client_alternate_content_sources, class_name: "Katello::ContentCredential"
    belongs_to :ssl_client_key, inverse_of: :ssl_key_alternate_content_sources, class_name: "Katello::ContentCredential"
    belongs_to :http_proxy, inverse_of: :alternate_content_sources
    has_many :smart_proxy_alternate_content_sources, dependent: :destroy,
             inverse_of: :alternate_content_source
    has_many :smart_proxies, through: :smart_proxy_alternate_content_sources

    validates :base_url, if: :custom?, presence: true
    validates :verify_ssl, if: :custom?, exclusion: [nil]
    validates :alternate_content_source_type, inclusion: {
      in: ->(_) { ACS_TYPES },
      allow_blank: false,
      message: ->(_, _) { _("is not a valid type. Must be one of the following: %s") % ACS_TYPES.join(',') }
    }
    validates :content_type, if: :custom?, inclusion: {
      in: ->(_) { RepositoryTypeManager.defined_repository_types.keys & CONTENT_TYPES },
      allow_blank: false,
      message: ->(_, _) { _("is not allowed for ACS. Must be one of the following: %s") % (RepositoryTypeManager.defined_repository_types.keys & CONTENT_TYPES).join(',') }
    }
    validates_with Validators::AlternateContentSourcePathValidator, :attributes => [:base_url, :subpaths], :if => :custom?

    scoped_search on: :name, complete_value: true
    scoped_search on: :label, complete_value: true
    scoped_search on: :description, complete_value: true
    scoped_search on: :base_url, complete_value: true
    scoped_search on: :subpath, ext_method: :search_by_subpath
    scoped_search on: :content_type, complete_value: true
    scoped_search on: :alternate_content_source_type, complete_value: true
    scoped_search on: :upstream_username, complete_value: true
    scoped_search on: :smart_proxy_id, relation: :smart_proxy_alternate_content_sources, validator: ScopedSearch::Validators::INTEGER, only_explicit: true

    def backend_service(smart_proxy)
      @service ||= ::Katello::Pulp3::AlternateContentSource.new(self, smart_proxy)
    end

    def custom?
      alternate_content_source_type == 'custom'
    end

    def self.with_type(content_type)
      where(content_type: content_type)
    end

    def self.search_by_subpath(_key, operator, value)
      conditions = sanitize_sql_for_conditions(["? #{operator} ANY (subpaths)", value_to_sql(operator, value)])
      { conditions: conditions }
    end
  end
end
