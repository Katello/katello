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

  def test_http_downloader_bad_param
    Setting[:cdn_ssl_version] = 'Foo'
    assert_raise RuntimeError do
      Katello::Resources::CDN::CdnResource.new('http://foo.com')
    end
  end
end
