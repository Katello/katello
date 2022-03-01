module Katello
  class CdnConfiguration < Katello::Model
    include Encryptable
    self.inheritance_column = nil
    CDN_TYPE = 'redhat_cdn'.freeze
    UPSTREAM_SERVER_TYPE = 'upstream_server'.freeze
    AIRGAPPED_TYPE = 'airgapped'.freeze

    TYPES = [CDN_TYPE, UPSTREAM_SERVER_TYPE, AIRGAPPED_TYPE].freeze

    belongs_to :organization, :inverse_of => :cdn_configuration

    belongs_to :ssl_ca_credential, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_ca_cdn_configurations

    encrypts :password
    validates :password, presence: true, if: :upstream_server?
    validates :username, presence: true, if: :upstream_server?
    validates :upstream_organization_label, presence: true, if: :upstream_server?

    validates :url, presence: true, unless: :airgapped?
    validates_with Validators::KatelloUrlFormatValidator, attributes: :url, unless: :airgapped?
    validates_with Validators::KatelloLabelFormatValidator, attributes: :upstream_organization_label, if: proc { upstream_organization_label.present? }
    validate :non_redhat_configuration, if: :upstream_server?

    before_validation :reset_fields

    def ssl_ca
      ssl_ca_credential&.content
    end

    def redhat_cdn?
      type == CDN_TYPE
    end

    def airgapped?
      type == AIRGAPPED_TYPE
    end

    def upstream_server?
      type == UPSTREAM_SERVER_TYPE
    end

    private

    def reset_fields
      return if upstream_server?

      self.url = nil if airgapped?
      self.url ||= SETTINGS[:katello][:redhat_repository_url] if redhat_cdn?
      self.username = nil
      self.password = nil
      self.upstream_organization_label = nil
      self.ssl_ca_credential_id = nil
      self.upstream_content_view_label = nil
      self.upstream_lifecycle_environment_label = nil
      self.ssl_cert = nil
      self.ssl_key = nil
    end

    def non_redhat_configuration
      if username.blank? || password.blank? || upstream_organization_label.blank? || ssl_ca_credential_id.blank?
        errors.add(:base, _("Username, Password, Upstream Organization Label, and SSL CA Credential are required when using an upstream Foreman server."))
      end
    end
  end
end
