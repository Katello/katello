require 'katello_test_helper'

module ::Actions::Katello::CdnConfiguration
  class UpdateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction

    def setup
      @action_class = ::Actions::Katello::CdnConfiguration::Update
      @action = create_action @action_class
      @organization = taxonomies(:empty_organization)
      @cdn_configuration = @organization.cdn_configuration
      @credential = FactoryBot.create(:katello_content_credential, organization: @organization)
      @library = ::Katello::KTEnvironment.find(katello_environments(:library).id)
      @library_view = ::Katello::ContentView.find(katello_content_views(:library_view).id)
    end

    def keypair
      key = OpenSSL::PKey::RSA.new(2048)
      cert = OpenSSL::X509::Certificate.new
      cert.public_key = key.public_key
      cert.not_before  = Time.now
      cert.not_after   = Time.now + 1000
      cert.sign key, OpenSSL::Digest.new('SHA256')

      {
        cert: cert,
        key: key,
        joined: "#{key.to_pem}#{cert.to_pem}",
      }
    end

    def test_plans_katello_cdn # rubocop:disable Metrics/AbcSize
      attrs = {
        type: Katello::CdnConfiguration::NETWORK_SYNC,
        url: 'http://newcdn.example.com',
        ssl_ca_credential_id: @credential.id,
        username: 'test_username',
        password: 'test_password',
        upstream_organization_label: @organization.label,
        upstream_content_view_label: @library_view.label,
        upstream_lifecycle_environment_label: @library.label,
      }
      ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:organization).returns(@organization)
      ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:content_view_id).returns(2)
      ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:lifecycle_environment_id).returns(2)

      certs = keypair
      ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:debug_certificate).returns(certs[:joined])

      root_repo = ::Katello::RootRepository.redhat.in_organization(@organization).first
      ::Katello::RootRepository.expects(:in_organization).returns([root_repo])

      ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:repository_url).with(
          content_label: root_repo.library_instance.content.label,
          arch: root_repo.arch,
          major: root_repo.major,
          minor: root_repo.minor
      ).returns('https://www.example.com')

      plan_action(@action, @cdn_configuration, attrs)

      @cdn_configuration.reload

      assert_equal attrs[:url], @cdn_configuration.url
      assert_equal certs[:cert], OpenSSL::X509::Certificate.new(@cdn_configuration.ssl_cert)
      assert_equal attrs[:ssl_ca_credential_id], @cdn_configuration.ssl_ca_credential_id
      assert_equal attrs[:username], @cdn_configuration.username
      assert_equal attrs[:password], @cdn_configuration.password
      assert_equal attrs[:upstream_organization_label], @cdn_configuration.upstream_organization_label
      assert_equal attrs[:upstream_content_view_label], @cdn_configuration.upstream_content_view_label
      assert_equal attrs[:upstream_lifecycle_environment_label], @cdn_configuration.upstream_lifecycle_environment_label
    end

    def test_plans_redhat_cdn
      attrs = {
        type: ::Katello::CdnConfiguration::CDN_TYPE,
      }

      plan_action(@action, @cdn_configuration, attrs)

      @cdn_configuration.reload

      assert_equal ::Katello::Resources::CDN::CdnResource.redhat_cdn_url, @cdn_configuration.url
      assert_nil @cdn_configuration.ssl_cert
      assert_nil @cdn_configuration.ssl_key
      assert_nil @cdn_configuration.ssl_ca_credential_id
      assert_nil @cdn_configuration.username
      assert_nil @cdn_configuration.password
      assert_nil @cdn_configuration.upstream_organization_label
    end

    def test_plans_custom_cdn
      attrs = {
        type: ::Katello::CdnConfiguration::CUSTOM_CDN_TYPE,
        url: 'http://newcdn.example.com',
        ssl_ca_credential_id: @credential.id,
      }

      plan_action(@action, @cdn_configuration, attrs)

      @cdn_configuration.reload

      assert_equal attrs[:url], @cdn_configuration.url
      assert_equal @credential.id, @cdn_configuration.ssl_ca_credential_id
      assert_nil @cdn_configuration.username
      assert_nil @cdn_configuration.password
      assert_nil @cdn_configuration.upstream_organization_label
    end

    def test_plans_airgapped
      attrs = {
        type: ::Katello::CdnConfiguration::EXPORT_SYNC,
      }
      refute @cdn_configuration.export_sync?
      refute_nil @cdn_configuration.url

      plan_action(@action, @cdn_configuration, attrs)
      @cdn_configuration.reload

      assert @cdn_configuration.export_sync?
      assert_nil @cdn_configuration.url
      assert_nil @cdn_configuration.ssl_cert
      assert_nil @cdn_configuration.ssl_key
      assert_nil @cdn_configuration.ssl_ca_credential_id
      assert_nil @cdn_configuration.username
      assert_nil @cdn_configuration.password
      assert_nil @cdn_configuration.upstream_organization_label
    end
  end
end
