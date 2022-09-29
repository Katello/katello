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
end
