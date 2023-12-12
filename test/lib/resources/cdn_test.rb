require 'katello_test_helper'
class CdnResourceTest < ActiveSupport::TestCase
  def test_http_downloader_tlsv1
    Setting[:cdn_min_tls_version] = 'TLSv1'
    cdn_resource = Katello::Resources::CDN::CdnResource.new('http://foo.com')
    assert_equal cdn_resource.http_downloader.min_version, OpenSSL::SSL::TLS1_VERSION
  end

  def test_http_downloader_tlsv11
    Setting[:cdn_min_tls_version] = 'TLSv1.1'
    cdn_resource = Katello::Resources::CDN::CdnResource.new('http://foo.com')
    assert_equal cdn_resource.http_downloader.min_version, OpenSSL::SSL::TLS1_1_VERSION
  end

  def test_http_downloader_tlsv12
    Setting[:cdn_min_tls_version] = 'TLSv1.2'
    cdn_resource = Katello::Resources::CDN::CdnResource.new('http://foo.com')
    assert_equal cdn_resource.http_downloader.min_version, OpenSSL::SSL::TLS1_2_VERSION
  end

  def test_http_downloader_tlsv13
    # TLSv1.3 is unavailable in some environments, for example the EL7 builders at
    # ci.theforeman.org. This check should be removable when those are upgraded to
    # EL8 or later. See https://github.com/theforeman/foreman-infra/issues/1706
    unless defined?(OpenSSL::SSL::TLS1_3_VERSION)
      skip "TLSv1.3 is unavailable in the current environment"
    end

    Setting[:cdn_min_tls_version] = 'TLSv1.3'
    cdn_resource = Katello::Resources::CDN::CdnResource.new('http://foo.com')
    assert_equal cdn_resource.http_downloader.min_version, OpenSSL::SSL::TLS1_3_VERSION
  end

  def test_http_downloader_default_version
    cdn_resource = Katello::Resources::CDN::CdnResource.new('http://foo.com')

    default_min_tls_version = defined?(OpenSSL::SSL::TLS1_3_VERSION) ? OpenSSL::SSL::TLS1_3_VERSION : OpenSSL::SSL::TLS1_2_VERSION
    assert_equal cdn_resource.http_downloader.min_version, default_min_tls_version
  end

  def test_http_proxy_no_cacert
    proxy = FactoryBot.create(:http_proxy, :url => 'http://foo.com:1000',
                              :username => 'admin',
                              :password => 'password',
                              :cacert => "")
    Katello::Resources::CDN::CdnResource.any_instance.stubs(:proxy).returns(proxy)
    OpenSSL::X509::Store.any_instance.expects(:add_file)
    Foreman::Util.expects(:add_ca_bundle_to_store).never
    Katello::Resources::CDN::CdnResource.new('http://foo.com', ssl_ca_file: "lol")
  end

  def test_http_downloader_bad_param
    Setting[:cdn_min_tls_version] = 'Foo'
    assert_raise RuntimeError do
      Katello::Resources::CDN::CdnResource.new('http://foo.com')
    end
  end

  def test_custom_cdn_auth
    organization = taxonomies(:empty_organization)
    credential = FactoryBot.create(:katello_content_credential, organization: organization)
    product = ::Katello::Product.find_by(cp_id: 'redhat_empty')
    attrs = {
      type: ::Katello::CdnConfiguration::CUSTOM_CDN_TYPE,
      url: 'http://newcdn.example.com',
      ssl_ca_credential_id: credential.id,
      custom_cdn_auth_enabled: true
    }
    organization.cdn_configuration.update(attrs)
    product.expects(:certificate).once.returns('')
    product.expects(:key).once.returns('')
    OpenSSL::X509::Certificate.expects(:new).once.returns('mock cert')
    OpenSSL::PKey::RSA.expects(:new).once.returns('mock key')
    cdn_resource = Katello::Resources::CDN::CdnResource.create(product: product, cdn_configuration: organization.cdn_configuration)
    cdn_resource_options = cdn_resource.instance_variable_get(:@options)
    assert_equal 'mock cert', cdn_resource_options[:ssl_client_cert]
    assert_equal 'mock key', cdn_resource_options[:ssl_client_key]
  end
end
