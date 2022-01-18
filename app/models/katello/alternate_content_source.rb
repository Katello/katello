module Katello
  class AlternateContentSource < Katello::Model
    include Ext::LabelFromName
    include Encryptable

    self.table_name = :katello_alternate_content_sources

    # TODO: cdn, rhui
    ALLOWED_TYPES = %w(custom).freeze

    encrypts :upstream_password

    belongs_to :ssl_ca_cert, :inverse_of => :ssl_ca_alternate_content_sources, :class_name => "Katello::ContentCredential"
    belongs_to :ssl_client_cert, :inverse_of => :ssl_client_alternate_content_sources, :class_name => "Katello::ContentCredential"
    belongs_to :ssl_client_key, :inverse_of => :ssl_key_alternate_content_sources, :class_name => "Katello::ContentCredential"
    belongs_to :http_proxy, :class_name => "HttpProxy"
    has_many :smart_proxy_alternate_content_sources

    def backend_service(smart_proxy)
      @service ||= ::Katello::Pulp3::AlternateContentSource.new(self, smart_proxy)
    end

    def custom?
      alternate_content_source_type == 'custom'
    end
  end
end
