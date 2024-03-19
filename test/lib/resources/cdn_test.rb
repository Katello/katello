require 'katello_test_helper'
class CdnResourceTest < ActiveSupport::TestCase
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
