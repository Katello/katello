module Katello
  class CdnConfiguration < Katello::Model
    include Encryptable

    belongs_to :organization, :inverse_of => :cdn_configuration

    belongs_to :ssl_ca_credential, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_ca_cdn_configurations

    encrypts :password

    validates_with Validators::KatelloLabelFormatValidator, :attributes => :organization_label, :if => proc { organization_label.present? }
    validates :url, presence: true

    def ssl_ca
      ssl_ca_credential&.content
    end

    def redhat?
      username.blank? && password.blank? && organization_label.blank? && ssl_ca_credential_id.blank?
    end
  end
end
