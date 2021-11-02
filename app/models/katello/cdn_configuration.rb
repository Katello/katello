module Katello
  class CdnConfiguration < Katello::Model
    include Encryptable

    belongs_to :organization, :inverse_of => :cdn_configuration

    belongs_to :ssl_ca_credential, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_ca_cdn_configurations

    encrypts :password

    validates :url, presence: true
    validates_with Validators::KatelloUrlFormatValidator, attributes: :url
    validates_with Validators::KatelloLabelFormatValidator, attributes: :upstream_organization_label, if: proc { upstream_organization_label.present? }
    validate :non_redhat_configuration, unless: :redhat?

    def ssl_ca
      ssl_ca_credential&.content
    end

    def redhat?
      username.blank? && password.blank? && upstream_organization_label.blank? && ssl_ca_credential_id.blank?
    end

    private

    def non_redhat_configuration
      errors.add(:base, _("Username, Password, Upstream Organization Label, and SSL CA Credential are required when using a non-Red Hat CDN."))
    end
  end
end
