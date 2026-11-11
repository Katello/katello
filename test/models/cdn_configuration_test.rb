require 'katello_test_helper'

module Katello
  class CdnConfigurationTest < ActiveSupport::TestCase
    NON_REDHAT_FIELDS = [:username, :password, :upstream_organization_label, :ssl_ca_credential_id].freeze

    def test_redhat_cdn
      config = FactoryBot.build(:katello_cdn_configuration, :redhat_cdn)

      NON_REDHAT_FIELDS.each do |field|
        assert_nil config.attributes[field.to_s]
      end

      assert config.redhat_cdn?
      assert config.valid?
    end

    def test_redhat_cdn_preserves_supported_urls
      config = taxonomies(:empty_organization).cdn_configuration

      ['https://cdn.redhat.com', 'https://cdn-eu.redhat.com', 'https://cdn-us.redhat.com'].each do |url|
        config.update!(type: CdnConfiguration::CDN_TYPE, url: url)
        assert_equal url, config.reload.url
      end
    end

    def test_redhat_cdn_normalizes_trailing_slashes
      config = taxonomies(:empty_organization).cdn_configuration

      config.update!(type: CdnConfiguration::CDN_TYPE, url: 'https://cdn-eu.redhat.com/')

      assert_equal 'https://cdn-eu.redhat.com', config.reload.url
    end

    def test_redhat_cdn_rejects_unsupported_urls
      ['https://cdn.example.com', 'http://cdn-eu.redhat.com', 'https://cdn-unknown.redhat.com',
       'https://cdn-eu.redhat.com:8443', 'https://cdn-eu.redhat.com.example.com',
       'https://cdn-eu.redhat.com/content'].each do |url|
        config = FactoryBot.build(:katello_cdn_configuration, :redhat_cdn, url: url)

        refute config.valid?, "Expected #{url} to be rejected"
        assert config.errors.of_kind?(:url, :inclusion)
        assert_equal url, config.url
      end
    end

    def test_redhat_cdn_accepts_configured_default
      default_url = 'https://cdn.example.com'
      original_default_url = SETTINGS[:katello][:redhat_repository_url]
      SETTINGS[:katello][:redhat_repository_url] = default_url
      config = FactoryBot.build(:katello_cdn_configuration, :redhat_cdn, url: default_url)

      assert config.valid?
      assert_equal default_url, config.url
    ensure
      SETTINGS[:katello][:redhat_repository_url] = original_default_url
    end

    def test_redhat_cdn_defaults_missing_urls
      default_url = 'https://cdn.example.com/'
      original_default_url = SETTINGS[:katello][:redhat_repository_url]
      SETTINGS[:katello][:redhat_repository_url] = default_url

      [nil, ''].each do |url|
        config = FactoryBot.build(:katello_cdn_configuration, :redhat_cdn, url: url)

        assert config.valid?
        assert_equal default_url.chomp('/'), config.url
      end
    ensure
      SETTINGS[:katello][:redhat_repository_url] = original_default_url
    end

    def test_redhat_cdn_defaults_an_unchanged_unsupported_url
      original_default_url = SETTINGS[:katello][:redhat_repository_url]
      SETTINGS[:katello][:redhat_repository_url] = 'https://cdn.example.com/'
      config = taxonomies(:empty_organization).cdn_configuration
      config.update_columns(type: CdnConfiguration::CDN_TYPE, url: 'https://old.example.com')
      config.reload

      config.save!

      assert_equal 'https://cdn.example.com', config.reload.url
    ensure
      SETTINGS[:katello][:redhat_repository_url] = original_default_url
    end

    def test_redhat_cdn_rejects_an_unsupported_update
      config = taxonomies(:empty_organization).cdn_configuration
      config.update!(type: CdnConfiguration::CDN_TYPE, url: 'https://cdn-eu.redhat.com')

      refute config.update(url: 'https://cdn.example.com')
      assert config.errors.of_kind?(:url, :inclusion)
      assert_equal 'https://cdn-eu.redhat.com', config.reload.url
    end

    def test_switching_to_redhat_cdn_defaults_an_inherited_upstream_url
      [CdnConfiguration::CUSTOM_CDN_TYPE, CdnConfiguration::NETWORK_SYNC].each do |type|
        config = upstream_configuration(type)
        config.update!(type: CdnConfiguration::CDN_TYPE)

        assert_equal SETTINGS[:katello][:redhat_repository_url], config.reload.url
        NON_REDHAT_FIELDS.each do |field|
          assert_predicate config.public_send(field), :blank?
        end
      end
    end

    def test_switching_to_redhat_cdn_preserves_an_explicit_sovereign_endpoint
      url = 'https://cdn-eu.redhat.com'
      [CdnConfiguration::CUSTOM_CDN_TYPE, CdnConfiguration::NETWORK_SYNC].each do |type|
        config = upstream_configuration(type)
        config.update!(type: CdnConfiguration::CDN_TYPE, url: url)

        assert_equal url, config.reload.url
        NON_REDHAT_FIELDS.each do |field|
          assert_predicate config.public_send(field), :blank?
        end
      end
    end

    def test_switching_to_redhat_cdn_rejects_an_explicit_unsupported_endpoint
      [CdnConfiguration::CUSTOM_CDN_TYPE, CdnConfiguration::NETWORK_SYNC].each do |type|
        config = upstream_configuration(type)
        original_url = config.url

        refute config.update(type: CdnConfiguration::CDN_TYPE, url: 'https://cdn.example.com')
        assert config.errors.of_kind?(:url, :inclusion)
        assert_equal type, config.reload.type
        assert_equal original_url, config.url
      end
    end

    def test_switching_to_redhat_cdn_rejects_an_explicit_unchanged_unsupported_endpoint
      config = upstream_configuration(CdnConfiguration::CUSTOM_CDN_TYPE)
      url = config.url
      config.assign_attributes('type' => CdnConfiguration::CDN_TYPE, 'url' => url)

      2.times do
        refute config.valid?
        assert config.errors.of_kind?(:url, :inclusion)
        assert_equal url, config.url
      end
    end

    def test_switching_from_custom_cdn_preserves_an_unchanged_sovereign_endpoint
      url = 'https://cdn-eu.redhat.com'
      config = upstream_configuration(CdnConfiguration::CUSTOM_CDN_TYPE, url: url)
      config.update!(type: CdnConfiguration::CDN_TYPE, url: url)

      assert_equal url, config.reload.url
    end

    def test_redhat_cdn_preserves_the_selected_endpoint_when_url_is_omitted
      config = taxonomies(:empty_organization).cdn_configuration

      ['https://cdn-eu.redhat.com', 'https://cdn-us.redhat.com'].each do |url|
        config.update!(type: CdnConfiguration::CDN_TYPE, url: url)
        config.update!(type: CdnConfiguration::CDN_TYPE)

        assert_equal url, config.reload.url
      end
    end

    def test_custom_cdn
      config = FactoryBot.build(:katello_cdn_configuration, :custom_cdn)
      assert config.custom_cdn?
      assert config.valid?
      config.assign_attributes(url: nil)
      refute config.valid?
    end

    def test_non_redhat_configuration
      NON_REDHAT_FIELDS.each do |field|
        config = FactoryBot.build(:katello_cdn_configuration, :upstream_server)

        config.assign_attributes(field => 'Something')
        refute config.valid?
        assert_match(/when using an upstream Foreman server/, config.errors.messages[:base].join(" "))
      end
    end

    def test_redhat_cdn_host
      config = FactoryBot.build(:katello_cdn_configuration, :custom_cdn)

      ['cdn.redhat.com', 'cdn-eu.redhat.com', 'cdn-us.redhat.com'].each do |host|
        config.url = "https://#{host}/content"
        assert config.redhat_cdn_host?, "Expected #{host} to be a Red Hat CDN host"
      end

      ['satellite.example.redhat.com', 'internal.fqdn.redhat.com'].each do |host|
        config.url = "https://#{host}/pub/repos"
        refute config.redhat_cdn_host?, "Expected #{host} NOT to be a Red Hat CDN host"
      end

      config.url = 'https://cdn.example.com/content'
      refute config.redhat_cdn_host?

      config.url = 'not a url'
      refute config.redhat_cdn_host?
    end

    def test_types_updated_correctly
      org = Organization.first
      content_credential = ContentCredential.create!(:name => "CA",
                                                     content_type: ContentCredential::CERT_TYPE,
                                                     :content => "Foo", :organization => org)
      config = org.cdn_configuration
      assert config.redhat_cdn?

      config.update!(type: ::Katello::CdnConfiguration::NETWORK_SYNC,
                     username: 'Foo',
                     password: 'great',
                     upstream_organization_label: 'GreatOrg',
                     url: 'http://foo.com',
                     ssl_ca_credential_id: content_credential.id)

      assert config.network_sync?

      # Now update to custom cdn
      config.update!(type: ::Katello::CdnConfiguration::CUSTOM_CDN_TYPE, custom_cdn_auth_enabled: true)
      assert config.custom_cdn?
      assert_empty config.username
      assert_empty config.password
      assert_empty config.upstream_organization_label
      assert_equal content_credential.id, config.ssl_ca_credential_id

      # Now update back to airgapped
      config.update!(type: ::Katello::CdnConfiguration::EXPORT_SYNC)
      assert config.export_sync?
      assert_empty config.url
      assert_empty config.username
      assert_empty config.password
      assert_empty config.upstream_organization_label
      assert_empty config.ssl_ca_credential_id

      # Finally update back to cdn
      config.update!(type: ::Katello::CdnConfiguration::CDN_TYPE)
      assert config.redhat_cdn?
      assert_equal config.url, SETTINGS[:katello][:redhat_repository_url]
    end

    private

    def upstream_configuration(type, url: 'https://upstream.example.com')
      organization = taxonomies(:empty_organization)
      config = organization.cdn_configuration
      credential = FactoryBot.create(:katello_content_credential, organization: organization)
      config.update!(type: type,
                     url: url,
                     username: 'upstream_user',
                     password: 'upstream_password',
                     upstream_organization_label: organization.label,
                     ssl_ca_credential_id: credential.id)
      config
    end
  end
end
