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
      config.update!(type: ::Katello::CdnConfiguration::CUSTOM_CDN_TYPE)
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
  end
end
