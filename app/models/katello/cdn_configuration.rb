module Katello
  class CdnConfiguration < Katello::Model
    belongs_to :organization, :inverse_of => :cdn_configuration
    belongs_to :ssl_ca_credential, :class_name => "Katello::GpgKey", :inverse_of => :ssl_ca_cdn_configurations
    belongs_to :ssl_cert_credential, :class_name => "Katello::GpgKey", :inverse_of => :ssl_cert_cdn_configurations
    belongs_to :ssl_key_credential, :class_name => "Katello::GpgKey", :inverse_of => :ssl_key_cdn_configurations
  end
end
