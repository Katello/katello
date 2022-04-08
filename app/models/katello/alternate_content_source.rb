module Katello
  class AlternateContentSource < Katello::Model
    include Ext::LabelFromName
    include Encryptable
    include Katello::Authorization::SyncPlan
    include ForemanTasks::Concerns::ActionSubject
    include ::ScopedSearchExtensions

    # TODO: optional validations depending on ACS type
    #  -> e.g. optionally validate null:false for content_type because
    #     product ACSs can create smart proxy ACSs of any content type.

    self.table_name = :katello_alternate_content_sources

    # TODO: product, rhui
    ACS_TYPES = %w(custom).freeze
    CONTENT_TYPES = [::Katello::Repository::YUM_TYPE, ::Katello::Repository::FILE_TYPE].freeze

    encrypts :upstream_password

    belongs_to :ssl_ca_cert, inverse_of: :ssl_ca_alternate_content_sources, class_name: "Katello::ContentCredential"
    belongs_to :ssl_client_cert, inverse_of: :ssl_client_alternate_content_sources, class_name: "Katello::ContentCredential"
    belongs_to :ssl_client_key, inverse_of: :ssl_key_alternate_content_sources, class_name: "Katello::ContentCredential"
    belongs_to :http_proxy, class_name: "HttpProxy"
    has_many :smart_proxy_alternate_content_sources, dependent: :destroy,
             inverse_of: :alternate_content_source
    has_many :smart_proxies, through: :smart_proxy_alternate_content_sources

    scoped_search on: :name, complete_value: true
    scoped_search on: :label, complete_value: true
    scoped_search on: :description, complete_value: true
    scoped_search on: :base_url, complete_value: true
    scoped_search on: :content_type, complete_value: true
    scoped_search on: :alternate_content_source_type, complete_value: true
    scoped_search on: :upstream_username, complete_value: true

    def backend_service(smart_proxy)
      @service ||= ::Katello::Pulp3::AlternateContentSource.new(self, smart_proxy)
    end

    def custom?
      alternate_content_source_type == 'custom'
    end

    def self.with_type(content_type)
      where(content_type: content_type)
    end
  end
end
