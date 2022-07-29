module Katello
  class CdnConfiguration < Katello::Model
    include Encryptable
    self.inheritance_column = nil
    CDN_TYPE = 'redhat_cdn'.freeze
    NETWORK_SYNC = 'network_sync'.freeze
    EXPORT_SYNC = 'export_sync'.freeze

    TYPES = [CDN_TYPE, NETWORK_SYNC, EXPORT_SYNC].freeze

    belongs_to :organization, :inverse_of => :cdn_configuration

    belongs_to :ssl_ca_credential, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_ca_cdn_configurations

    encrypts :password
    validates :password, presence: true, if: :network_sync?
    validates :username, presence: true, if: :network_sync?
    validates :upstream_organization_label, presence: true, if: :network_sync?

    validates :url, presence: true, unless: :export_sync?
    validates_with Validators::KatelloUrlFormatValidator, attributes: :url, unless: :export_sync?
    validates_with Validators::KatelloLabelFormatValidator, attributes: :upstream_organization_label, if: proc { upstream_organization_label.present? }
    validate :non_redhat_configuration, if: :network_sync?

    before_validation :reset_fields

    def ssl_ca
      ssl_ca_credential&.content
    end

    def redhat_cdn?
      type == CDN_TYPE
    end

    def redhat_cdn_url?
      Katello::Resources::CDN::CdnResource.redhat_cdn?(url)
    end

    def export_sync?
      type == EXPORT_SYNC
    end

    def network_sync?
      type == NETWORK_SYNC
    end

    private

    def reset_fields
      return if network_sync?

      self.url = nil if export_sync?
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
