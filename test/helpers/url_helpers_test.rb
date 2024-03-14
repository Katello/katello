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
    @host.content_facet.assign_single_environment(
      :lifecycle_environment_id => @env.id,
      :content_view_id => @cv.id
    )
  end

  test 'repository_url must render the right path based on host configuration' do
    @host.update(organization_id: @host.single_content_view.organization_id)
    path = "http://#{@host.content_source.hostname}/pulp/content/#{@host.single_lifecycle_environment.organization.label}/#{@host.single_lifecycle_environment.label}/custom/zoo/zoo/zoo.iso".freeze
    repository_url('/custom/zoo/zoo/zoo.iso')
    assert_equal path, repository_url('/custom/zoo/zoo/zoo.iso')

    @host.content_facet.assign_single_environment(lifecycle_environment_id: @env.id, content_view_id: katello_content_views(:library_dev_view).id)
    @host.reload
    path = "http://#{@host.content_source.hostname}/pulp/content/#{@host.single_lifecycle_environment.organization.label}/#{@host.single_lifecycle_environment.label}/#{@host.single_content_view.label}/custom/zoo/zoo/zoo.iso".freeze
    assert_equal path, repository_url('/custom/zoo/zoo/zoo.iso')
  end

  test 'repository_url should error out if there are multiple content environments without the default org view' do
    @host.update(organization_id: @host.single_content_view.organization_id)
    ::Katello::ContentViewEnvironmentContentFacet.destroy_all
    ::Katello::ContentViewEnvironmentContentFacet.create(content_facet_id: @host.content_facet.id, content_view_environment_id: ::Katello::ContentViewEnvironment.find_by(name: 'Library and Dev Content View Environment').id)
    ::Katello::ContentViewEnvironmentContentFacet.create(content_facet_id: @host.content_facet.id, content_view_environment_id: ::Katello::ContentViewEnvironment.find_by(name: 'Published Library Composite Content View Environment').id)
    @host.reload
    message = "Host #{@host.name} must be subscribed to only a single content view & environment or subscribe to the default organization content view for liveimg provisioning."
    assert_raises_with_message ::Katello::Errors::MultiEnvironmentNotSupportedError, message do
      repository_url('/custom/zoo/zoo/zoo.iso')
    end
  end
end
