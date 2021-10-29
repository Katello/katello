module Katello
  class CdnConfiguration < Katello::Model
    include Encryptable

    belongs_to :organization, :inverse_of => :cdn_configuration

    belongs_to :ssl_ca_credential, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_ca_cdn_configurations

    encrypts :password

    validates :url, presence: true
    validates :username, presence: true, unless: :redhat?
    validates :password, presence: true, unless: :redhat?
    validates :upstream_organization_label, presence: true, unless: :redhat?
    validates :ssl_ca_credential_id, presence: true, unless: :redhat?
    validates_with Validators::KatelloLabelFormatValidator, attributes: :upstream_organization_label, if: proc { upstream_organization_label.present? }

    def ssl_ca
      ssl_ca_credential&.content
    end

    def redhat?
      username.blank? && password.blank? && upstream_organization_label.blank? && ssl_ca_credential_id.blank?
    end
  end
end
