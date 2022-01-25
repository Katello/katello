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

      config.update!(type: ::Katello::CdnConfiguration::UPSTREAM_SERVER_TYPE,
                     username: 'Foo',
                     password: 'great',
                     upstream_organization_label: 'GreatOrg',
                     url: 'http://foo.com',
                     ssl_ca_credential_id: content_credential.id)

      assert config.upstream_server?

      # Now update back to airgapped
      config.update!(type: ::Katello::CdnConfiguration::AIRGAPPED_TYPE)
      assert config.airgapped?
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
