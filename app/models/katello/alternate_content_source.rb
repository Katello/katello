module Katello
  class AlternateContentSource < Katello::Model
    self.table_name = :katello_alternate_content_sources
    belongs_to :ssl_ca_cert, :inverse_of => :ssl_ca_alternate_content_sources, :class_name => "Katello::ContentCredential"
    belongs_to :ssl_client_cert, :inverse_of => :ssl_client_alternate_content_sources, :class_name => "Katello::ContentCredential"
    belongs_to :ssl_client_key, :inverse_of => :ssl_key_alternate_content_sources, :class_name => "Katello::ContentCredential"
    belongs_to :http_proxy, :class_name => "HttpProxy"
    has_many :smart_proxy_alternate_content_sources
  end
end
