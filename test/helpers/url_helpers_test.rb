require 'test_helper'
require 'katello_test_helper'

class UrlHelperBase < ActionView::TestCase
  include ApplicationHelper
  include Katello::KatelloUrlsHelper
end

class HostUrlHelpers < UrlHelperBase
  def setup
    @repo_with_distro = katello_repositories(:fedora_17_x86_64)
    @os = ::Redhat.create_operating_system('RedHat', '9', '0')
    @content_source = FactoryBot.create(:smart_proxy, :name => "foobar", :url => "http://capsule.com/")
    @arch = architectures(:x86_64)
    @cv = @repo_with_distro.content_view
    @env = @repo_with_distro.environment
    @location = Location.new(
      name: 'Default Location',
      type: 'Location',
      ignore_types: ['ProvisioningTemplate', 'Hostgroup'],
      label: 'Default_Location',
      title: 'Default Location'
    )
    @organization = Organization.new(
      name: 'Default Organization',
      type: 'Organization',
      label: 'Default_Organization',
      title: 'Default Organization'
    )

    @host = FactoryBot.create(:host, :with_content, :architecture => @arch, :operatingsystem => @os,
                       :content_facet_attributes => { :content_source_id => @content_source.id },
                       :location => @location,
                       :organization => @organization
                      )
    cvenv = Katello::ContentViewEnvironment.find_by_cv_and_lce!(@cv.id, @env.id)
    @host.content_facet.content_view_environments = [cvenv]
  end

  test 'repository_url must render the right path based on host configuration' do
    @host.update(organization_id: @host.single_content_view.organization_id)
    path = "http://#{@host.content_source.hostname}/pulp/content/#{@host.single_lifecycle_environment.organization.label}/#{@host.single_lifecycle_environment.label}/custom/zoo/zoo/zoo.iso".freeze
    repository_url('/custom/zoo/zoo/zoo.iso')
    assert_equal path, repository_url('/custom/zoo/zoo/zoo.iso')

    cvenv = Katello::ContentViewEnvironment.find_by_cv_and_lce!(katello_content_views(:library_dev_view).id, @env.id)
    @host.content_facet.content_view_environments = [cvenv]
    @host.reload
    path = "http://#{@host.content_source.hostname}/pulp/content/#{@host.single_lifecycle_environment.organization.label}/#{@host.single_lifecycle_environment.label}/#{@host.single_content_view.label}/custom/zoo/zoo/zoo.iso".freeze
    assert_equal path, repository_url('/custom/zoo/zoo/zoo.iso')
  end

  test 'repository_url uses the first content view environment when the host has multiple' do
    @host.update(organization_id: @host.single_content_view.organization_id)
    first_cvenv = ::Katello::ContentViewEnvironment.find_by(name: 'Library and Dev Content View Environment')
    second_cvenv = ::Katello::ContentViewEnvironment.find_by(name: 'Published Library Composite Content View Environment')
    @host.content_facet.content_view_environments = [first_cvenv, second_cvenv]
    @host.reload

    path = "http://#{@host.content_source.hostname}/pulp/content/#{first_cvenv.lifecycle_environment.organization.label}/#{first_cvenv.lifecycle_environment.label}/#{first_cvenv.content_view.label}/custom/zoo/zoo/zoo.iso".freeze
    assert_equal path, repository_url('/custom/zoo/zoo/zoo.iso')
  end
end
