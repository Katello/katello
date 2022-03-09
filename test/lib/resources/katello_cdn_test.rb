require 'katello_test_helper'
class KatelloCdnResourceTest < ActiveSupport::TestCase
  def setup
    @organization = taxonomies(:empty_organization)
    @response_arch =  JSON.parse(read_test_file_data("test/fixtures/response_fixtures/katello_cdn_reponse_with_arch.json"))
    @response_version = JSON.parse(read_test_file_data("test/fixtures/response_fixtures/katelllo_cdn_response_with_version.json"))
  end

  def test_katello_cdn_repository_url_with_arch
    katello_cdn = ::Katello::Resources::CDN::KatelloCdn.new('https://test.com', {
                                                              organization_label: 'test',
                                                              content_view_label: 'test',
                                                              lifecycle_environment_label: 'test'
                                                            })

    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:organization).returns(@organization)
    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:content_view_id).returns(2)
    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:lifecycle_environment_id).returns(2)
    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:get).returns(@response_arch)

    assert_equal(katello_cdn.repository_url(content_label: 'rhel-6-server-els-rpms', arch: 'i386', major: nil, minor: nil),
                  "https://test.com/pulp/content/test/Library/content/els/rhel/server/6/6Server/i386/os/")
  end

  def test_katello_cdn_repository_url_with_version
    katello_cdn = ::Katello::Resources::CDN::KatelloCdn.new('https://test.com', {
                                                              organization_label: 'test',
                                                              content_view_label: 'test',
                                                              lifecycle_environment_label: 'test'
                                                            })

    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:organization).returns(@organization)
    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:content_view_id).returns(2)
    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:lifecycle_environment_id).returns(2)
    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:get).returns(@response_version)

    assert_equal(katello_cdn.repository_url(content_label: 'rhel-8-for-x86_64-baseos-rpms', arch: 'noarch', major: 8, minor: '8.3'),
                  "https://test.com/pulp/content/test/Library/content/dist/rhel8/8.3/x86_64/baseos/os/")
  end

  def test_katello_cdn_repository_url_throws_error_when_repo_not_found
    katello_cdn = ::Katello::Resources::CDN::KatelloCdn.new('https://test.com', {
                                                              organization_label: 'test',
                                                              content_view_label: 'test',
                                                              lifecycle_environment_label: 'test'
                                                            })

    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:organization).returns(@organization)
    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:content_view_id).returns(2)
    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:lifecycle_environment_id).returns(2)
    ::Katello::Resources::CDN::KatelloCdn.any_instance.expects(:get).returns("{}")

    exception = assert_raise RuntimeError do
      katello_cdn.repository_url(content_label: 'test', arch: 'noarch', major: '8', minor: '8server')
    end
    assert_equal(exception.message, "Repository with content label: 'test', arch: 'noarch', version: '8server' was not found in upstream organization 'test', content view 'test' and lifecycle environment 'test'")
  end
end
