module Katello
  class CdnConfiguration < Katello::Model
    include Encryptable
    self.inheritance_column = nil
    CDN_TYPE = 'redhat_cdn'.freeze
    NETWORK_SYNC = 'network_sync'.freeze
    EXPORT_SYNC = 'export_sync'.freeze
    CUSTOM_CDN_TYPE = 'custom_cdn'.freeze

    TYPES = [CDN_TYPE, NETWORK_SYNC, EXPORT_SYNC, CUSTOM_CDN_TYPE].freeze
    # Red Hat's public endpoints; .selectable_urls adds the configured default.
    REDHAT_CDN_URLS = %w[
      https://cdn.redhat.com
      https://cdn-eu.redhat.com
      https://cdn-us.redhat.com
    ].freeze
    REDHAT_CDN_HOST_PATTERN = /\Acdn(-[a-z]+)?\.redhat\.com\z/

    belongs_to :organization, :inverse_of => :cdn_configuration

    belongs_to :ssl_ca_credential, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_ca_cdn_configurations

    encrypts :password
    validates :password, presence: true, if: :network_sync?
    validates :username, presence: true, if: :network_sync?
    validates :upstream_organization_label, presence: true, if: :network_sync?

    validates :url, presence: true, unless: :export_sync?
    validate :redhat_cdn_url_supported, if: :redhat_cdn?
    validates_with Validators::KatelloURLFormatValidator, attributes: :url, unless: :export_sync?
    validates_with Validators::KatelloLabelFormatValidator, attributes: :upstream_organization_label, if: proc { upstream_organization_label.present? }
    validate :non_redhat_configuration, if: :network_sync?

    before_validation :reset_fields
    after_save { @url_explicitly_assigned = false }

    # capture if the url gets assigned. dirty tracking only tracks changes
    # and we need to know if the url was assigned even if it didn't change
    def url=(value)
      @url_assigned = true
      super
    end

    def self.selectable_urls
      (REDHAT_CDN_URLS + [SETTINGS[:katello][:redhat_repository_url]]).compact.map { |url| url.chomp('/') }.uniq
    end

    def ssl_ca
      ssl_ca_credential&.content
    end

    def redhat_cdn?
      type == CDN_TYPE
    end

    def custom_cdn?
      type == CUSTOM_CDN_TYPE
    end

    def custom_cdn_auth_enabled?
      custom_cdn_auth_enabled
    end

    def redhat_cdn_host?
      URI.parse(url).host&.match?(REDHAT_CDN_HOST_PATTERN)
    rescue URI::InvalidURIError
      false
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

      self[:url] = nil if export_sync?
      reset_redhat_cdn_url if redhat_cdn?
      self.username = nil
      self.password = nil
      self.upstream_organization_label = nil
      self.ssl_ca_credential_id = nil unless custom_cdn?
      self.upstream_content_view_label = nil
      self.upstream_lifecycle_environment_label = nil
      self.ssl_cert = nil
      self.ssl_key = nil
    end

    # A record can carry a URL inherited from another type, or one that predates a change
    # to the configured default. Keep it only when the caller asked for it explicitly,
    # so unrelated saves of such records keep working.
    def reset_redhat_cdn_url
      self[:url] = url.strip.chomp('/') if url.present?
      return if url.present? && (@url_assigned || self.class.selectable_urls.include?(url))

      self[:url] = SETTINGS[:katello][:redhat_repository_url]&.chomp('/')
    end

    def redhat_cdn_url_supported
      errors.add(:url, :inclusion) unless self.class.selectable_urls.include?(url)
    end

    def non_redhat_configuration
      if username.blank? || password.blank? || upstream_organization_label.blank? || ssl_ca_credential_id.blank?
        errors.add(:base, _("Username, Password, Upstream Organization Label, and SSL CA Credential are required when using an upstream Foreman server."))
      end
    end
  end
end
