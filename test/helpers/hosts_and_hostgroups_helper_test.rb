require 'test_helper'
require 'katello_test_helper'

class HostsAndHostGroupsHelperTestBase < ActionView::TestCase
  include ::Katello::HostsAndHostgroupsHelper
  include ApplicationHelper
  attr_accessor :params
end

class HostAndHostGroupsHelperLifecycleEnvironmentTests < HostsAndHostGroupsHelperTestBase
  def setup
    User.current = User.anonymous_api_admin

    @library = katello_environments(:library)
    @host =  FactoryBot.build(:host, :with_content, :with_subscription, :id => 343)
    content_facet = Katello::Host::ContentFacet.new(
      :content_view => katello_content_views(:library_dev_view),
      :lifecycle_environment => katello_environments(:library)
    )
    @host.content_facet = content_facet
    @host.organization = taxonomies(:organization1)
    @group = FactoryBot.build(:hostgroup)
    @smart_proxy = FactoryBot.create(:smart_proxy, :features => [FactoryBot.create(:feature, name: 'Pulp')])
  end

  def test_accessible_lifecycle_environments
    envs = accessible_lifecycle_environments(@library.organization, @host)
    assert_includes(envs, @library)
  end

  def test_accessible_lifecycle_environments_limited
    @host.save
    @host.reload
    User.current = FactoryBot.create(:user)
    envs = accessible_lifecycle_environments(@library.organization, @host)
    assert_equal([@host.content_facet.lifecycle_environment], envs)
  end

  def test_relevant_organizations
    org = Organization.new
    Organization.stubs(:my_organizations).returns([org])

    assert_equal [@host.organization], relevant_organizations(@host)
    @host.organization = nil
    assert_equal [org], relevant_organizations(@host)
  end

  def test_accessible_content_proxies_pulp2
    assert_includes accessible_content_proxies(@host), @smart_proxy
    assert_includes accessible_content_proxies(@group), @smart_proxy
  end

  def test_accessible_content_proxies
    proxy = FactoryBot.create(:smart_proxy, :with_pulp3)

    assert_includes accessible_content_proxies(@host), proxy
    assert_includes accessible_content_proxies(@group), proxy
  end

  def test_accessible_content_proxies_no_perms
    User.current = FactoryBot.create(:user)
    FactoryBot.create(:smart_proxy, :features => [FactoryBot.create(:feature, name: 'Pulp')])
    @host.content_facet.content_source = @smart_proxy

    assert_equal [@smart_proxy], accessible_content_proxies(@host)
  end
end

class HostsAndHostGroupsHelperKickstartRepositoryOptionsTest < HostsAndHostGroupsHelperTestBase
  def setup
    @repo_with_distro = katello_repositories(:fedora_17_x86_64)
    @os = ::Redhat.create_operating_system('RedHat', '9', '0')
    @content_source = FactoryBot.create(:smart_proxy, :name => "foobar", :url => "http://capsule.com/")
    @arch = architectures(:x86_64)
    @cv = @repo_with_distro.content_view
    @env = @repo_with_distro.environment
  end

  test "kickstart repository options should handle os - selected call with no params" do
    self.params = {}
    assert_empty kickstart_repository_options(nil)
  end

  test "kickstart_repository_options should handle os - selected call with all params" do
    self.params = {"host" => {
      "operatingsystem_id" => @os.id,
      "content_view_id" => @cv.id,
      "lifecycle_environment_id" => @env.id,
      "content_source_id" => @content_source.id,
      "architecture_id" => @arch.id
    }}.with_indifferent_access
    ret = [{:name => "boo" }]
    ::Operatingsystem.expects(:find).with(@os.id).returns(@os).at_least_once
    @os.expects(:kickstart_repos).returns(ret).with do |host|
      host.must_be_kind_of(::Host::Managed)
      assert_equal @os, host.os
      assert_equal @env, host.content_facet.lifecycle_environment
      assert_equal @cv, host.content_facet.content_view
      assert_equal @content_source, host.content_source
      assert_equal @arch, host.architecture
    end
    options = kickstart_repository_options(nil)
    refute_empty options
    assert_equal ret.first[:name], options.first.name
  end

  test "kickstart_repository_options should provide options for a populated host" do
    host = ::Host.new(:architecture => @arch, :operatingsystem => @os,
                      :content_facet_attributes => {:lifecycle_environment_id => @env.id,
                                                    :content_view_id => @cv.id,
                                                    :content_source_id => @content_source.id})
    ret = [{:name => "boo" }]

    @os.expects(:kickstart_repos).returns(ret).with do |param_host|
      param_host.must_be_kind_of(::Host::Managed)
      assert_equal @os, param_host.os
      assert_equal @env, param_host.content_facet.lifecycle_environment
      assert_equal @cv, param_host.content_facet.content_view
      assert_equal @content_source, param_host.content_source
      assert_equal @arch, param_host.architecture
    end

    options = kickstart_repository_options(host)
    refute_empty options
    assert_equal ret.first[:name], options.first.name
  end

  test "kickstart_repository_options should_handle_non_redhat_host" do
    hostgroup = ::Hostgroup.new(:operatingsystem => @os)
    host = ::Host.new(:architecture => @arch, :operatingsystem => operatingsystems(:opensuse), :hostgroup => hostgroup,
                      :content_facet_attributes => {:lifecycle_environment_id => @env.id,
                                                    :content_view_id => @cv.id,
                                                    :content_source_id => @content_source.id})

    options = kickstart_repository_options(host, :selected_host_group => hostgroup)
    assert_empty options
  end

  test "kickstart_repository_options should provide options for a populated hostgroup" do
    self.params = {}
    hostgroup = ::Hostgroup.new(
      :content_facet_attributes => {
        :lifecycle_environment_id => @env.id,
        :content_view_id => @cv.id })
    hostgroup.architecture = @arch
    hostgroup.operatingsystem = @os
    hostgroup.content_source = @content_source
    ret = [{:name => "boo" }]

    @os.expects(:kickstart_repos).returns(ret).with do |param_host|
      param_host.must_be_kind_of(::Host::Managed)
      assert_equal @os, param_host.os
      assert_equal @env, param_host.content_facet.lifecycle_environment
      assert_equal @cv, param_host.content_facet.content_view
      assert_equal @content_source, param_host.content_source
      assert_equal @arch, param_host.architecture
    end

    options = kickstart_repository_options(hostgroup)
    refute_empty options
    assert_equal ret.first[:name], options.first.name
  end

  test "kickstart_repository_options should provide options for a populated host with a selected_host_group" do
    host = ::Host.new
    hostgroup = ::Hostgroup.new(
      :content_facet_attributes => {
        :lifecycle_environment_id => @env.id,
        :content_view_id => @cv.id})
    hostgroup.architecture = @arch
    hostgroup.operatingsystem = @os
    hostgroup.content_source = @content_source

    ret = [{:name => "boo" }]

    @os.expects(:kickstart_repos).returns(ret).with do |param_host|
      param_host.must_be_kind_of(::Host::Managed)
      assert_equal @os, param_host.os
      assert_equal @env, param_host.content_facet.lifecycle_environment
      assert_equal @cv, param_host.content_facet.content_view
      assert_equal @content_source, param_host.content_source
      assert_equal @arch, param_host.architecture
    end

    options = kickstart_repository_options(host, :selected_host_group => hostgroup)
    refute_empty options
    assert_equal ret.first[:name], options.first.name
  end
end

class HostsAndHostGroupsHelperKickstartRepositoryIDTest < HostsAndHostGroupsHelperTestBase
  def setup
    @repo_with_distro = katello_repositories(:fedora_17_x86_64)
    @os = ::Redhat.create_operating_system('RedHat', '9', '0')
    @content_source = FactoryBot.create(:smart_proxy, :name => "foobar", :url => "http://capsule.com/")
    @arch = architectures(:x86_64)
    @cv = @repo_with_distro.content_view
    @env = @repo_with_distro.environment
    @hostgroup = ::Hostgroup.new
    @hostgroup.architecture = @arch
    @hostgroup.operatingsystem = @os
    @hostgroup.build_content_facet(
      :lifecycle_environment_id => @env.id,
      :content_view_id => @cv.id,
      :content_source => @content_source
    )

    @host = ::Host.new(:architecture => @arch, :operatingsystem => @os,
                       :content_facet_attributes => {:lifecycle_environment_id => @env.id,
                                                     :content_view_id => @cv.id,
                                                     :content_source_id => @content_source.id}
                      )
  end

  test "must return host or host group kickstart id" do
    repo_id = 1000
    @hostgroup.content_facet.kickstart_repository_id = repo_id
    assert_equal repo_id, kickstart_repository_id(@hostgroup)
    @host.content_facet.kickstart_repository_id = repo_id
    assert_equal repo_id, kickstart_repository_id(@host)
  end

  test "must handle  hosts or  host groups with medium_id but no kickstart_repository_id" do
    @hostgroup.content_facet.kickstart_repository_id = nil
    @hostgroup.medium_id = 1000
    assert_nil kickstart_repository_id(@hostgroup)

    @host.content_facet.kickstart_repository_id = nil
    @host.medium_id = 1000
    assert_nil kickstart_repository_id(@host)
  end

  test "must handle hosts or host groups with no medium_id or kickstart_repository_id" do
    id = 100
    option = mock
    option.expects(:id).returns(id).at_least_once
    @hostgroup.content_facet.kickstart_repository_id = nil
    @hostgroup.medium_id = nil
    expects(:kickstart_repository_options).with(@hostgroup, {}).returns([option])
    assert_equal id, kickstart_repository_id(@hostgroup)

    @host.content_facet.kickstart_repository_id = nil
    @host.medium_id = nil
    expects(:kickstart_repository_options).with(@host, {}).returns([option])
    assert_equal id, kickstart_repository_id(@host)
  end

  test "must handle nil hosts or host groups" do
    expects(:kickstart_repository_options).with(nil, {}).returns([])
    assert_nil kickstart_repository_id(nil)
  end

  test "must handle selected hosts or host groups" do
    id = 100
    @hostgroup.content_facet.kickstart_repository_id = id
    host = ::Host.new
    expects(:kickstart_repository_options).at_least_once.
      returns([OpenStruct.new(:id => id)])

    assert_equal id, kickstart_repository_id(host, :selected_host_group => @hostgroup)

    #if the host group had a medium_id lets make sure that gets used.
    @hostgroup.content_facet.kickstart_repository_id = nil
    @hostgroup.medium_id = id
    assert_nil kickstart_repository_id(::Host.new, :selected_host_group => @hostgroup)
  end
end

class HostAndHostGroupsHelperContentSourceTests < HostsAndHostGroupsHelperTestBase
  test 'options include inherited content source when provided' do
    smart_proxy = FactoryBot.build_stubbed(
      :smart_proxy,
      :features => [FactoryBot.create(:feature, name: 'Pulp')]
    )
    hostgroup = FactoryBot.build_stubbed(
      :hostgroup,
      :content_source => smart_proxy
    )
    assert_equal(
      hostgroup.content_source,
      fetch_content_source(FactoryBot.build_stubbed(:host), :selected_host_group => hostgroup)
    )
  end

  test 'if host has a content_source already, do not inherit from hostgroup' do
    smart_proxy_hostgroup = FactoryBot.build_stubbed(
      :smart_proxy,
      :features => [FactoryBot.create(:feature, name: 'Pulp')]
    )
    smart_proxy_host = FactoryBot.build_stubbed(
      :smart_proxy,
      :features => [FactoryBot.create(:feature, name: 'Pulp')]
    )
    hostgroup = FactoryBot.build_stubbed(
      :hostgroup,
      :content_source => smart_proxy_hostgroup
    )
    host = FactoryBot.build_stubbed(
      :host,
      :hostgroup => hostgroup
    )
    host.content_source = smart_proxy_host
    assert_equal(
      smart_proxy_host,
      fetch_content_source(host, :selected_host_group => hostgroup)
    )
  end
end
