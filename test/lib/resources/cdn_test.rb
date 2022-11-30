require 'katello_test_helper'
class CdnResourceTest < ActiveSupport::TestCase
  def test_http_downloader_v2
    Setting[:cdn_ssl_version] = 'SSLv23'
    cdn_resource = Katello::Resources::CDN::CdnResource.new('http://foo.com')
    assert_equal cdn_resource.http_downloader.ssl_version, 'SSLv23'
  end

  def test_http_downloader_tls
    Setting[:cdn_ssl_version] = 'TLSv1'
    cdn_resource = Katello::Resources::CDN::CdnResource.new('http://foo.com')
    assert_equal cdn_resource.http_downloader.ssl_version, 'TLSv1'
  end

  def test_http_downloader_no_version
    cdn_resource = Katello::Resources::CDN::CdnResource.new('http://foo.com')
    assert_nil cdn_resource.http_downloader.ssl_version
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
    Setting[:cdn_ssl_version] = 'Foo'
    assert_raise RuntimeError do
      Katello::Resources::CDN::CdnResource.new('http://foo.com')
    end
  end
end
