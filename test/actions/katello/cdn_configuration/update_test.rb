require 'katello_test_helper'

module ::Actions::Katello::CdnConfiguration
  class UpdateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    #include FactoryBot::Syntax::Methods

    def setup
      @action_class = ::Actions::Katello::CdnConfiguration::Update
      @action = create_action @action_class
      @organization = taxonomies(:empty_organization)
      @cdn_configuration = @organization.cdn_configuration
      @credentials = ::Katello::ContentCredential.where(organization: @organization)
      @credential = @credentials.first
    end

    def keypair
      key = OpenSSL::PKey::RSA.new(2048)
      cert = OpenSSL::X509::Certificate.new
      cert.public_key = key.public_key
      cert.not_before  = Time.now
      cert.not_after   = Time.now + 1000
      cert.sign key, OpenSSL::Digest::SHA256.new

      {
        cert: cert,
        key: key,
        joined: "#{key.to_pem}#{cert.to_pem}"
      }
    end

    def test_plans_katello_cdn
      @cdn_configuration.stubs(:redhat?).returns(false)

      attrs = {
        url: 'http://newcdn.example.com',
        ssl_ca_credential_id: @credential.id,
        username: 'test_username',
        password: 'test_password',
        organization_label: 'upstream_org'
      }

      certs = keypair
      ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:debug_certificate).returns(certs[:joined])

      times = ::Katello::RootRepository.redhat.in_organization(@organization).count
      ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:repository_url).returns('https://www.example.com').times(times)

      plan_action(@action, @cdn_configuration, attrs)

      @cdn_configuration.reload

      assert_equal attrs[:url], @cdn_configuration.url
      assert_equal certs[:cert], OpenSSL::X509::Certificate.new(@cdn_configuration.ssl_cert)
      assert_equal attrs[:ssl_ca_credential_id], @cdn_configuration.ssl_ca_credential_id
      assert_equal attrs[:username], @cdn_configuration.username
      assert_equal attrs[:password], @cdn_configuration.password
      assert_equal attrs[:organization_label], @cdn_configuration.organization_label
    end

    def test_plans_redhat_cdn
      attrs = {
        url: 'http://cdn.redhat.com',
        ssl_ca_credential_id: nil,
        username: '',
        password: '',
        organization_label: ''
      }

      plan_action(@action, @cdn_configuration, attrs)

      @cdn_configuration.reload

      assert_equal attrs[:url], @cdn_configuration.url
      assert_nil @cdn_configuration.ssl_cert
      assert_nil @cdn_configuration.ssl_key
      assert_nil @cdn_configuration.ssl_ca_credential_id
      assert_equal attrs[:username], @cdn_configuration.username
      assert_equal attrs[:password], @cdn_configuration.password
      assert_equal attrs[:organization_label], @cdn_configuration.organization_label
    end
  end
end
