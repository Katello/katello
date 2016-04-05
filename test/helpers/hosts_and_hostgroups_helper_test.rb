require 'test_helper'
require 'katello_test_helper'

class HostsAndHostGroupsHelperTestBase < ActionView::TestCase
  include ::Katello::HostsAndHostgroupsHelper
  include ApplicationHelper
  attr_accessor :params
  def setup
    self.params = {}
  end
end

class HostsAndHostGroupsHelperKickstartRepositoryOptionsTest < HostsAndHostGroupsHelperTestBase
  def setup
    @repo_with_distro = katello_repositories(:fedora_17_x86_64)
    @os = ::Redhat.create_operating_system('RedHat', '9', '0')
    @content_source = SmartProxy.create!(:name => "foobar", :url => "http://capsule.com/")
    @arch = architectures(:x86_64)
    @cv = @repo_with_distro.content_view
    @env  = @repo_with_distro.environment
  end

  test "kickstart repository options should handle os - selected call with no params" do
    self.params = {}
    assert_empty kickstart_repository_options(nil)
  end

  test "kickstart_repository_options should handle os - selected call with all params" do
    self.params = {
      "operatingsystem_id" => @os.id,
      "content_view_id" => @cv.id,
      "lifecycle_environment_id" => @env.id,
      "content_source_id" => @content_source.id,
      "architecture_id" => @arch.id
    }.with_indifferent_access
    ret = [{:name => "boo" }]
    ::Operatingsystem.expects(:find).with(@os.id).returns(@os).at_least_once
    @os.expects(:kickstart_repos).returns(ret).with do |host|
      host.must_be_kind_of(::Host::Managed)
      host.os.must_equal(@os)
      host.content_facet.lifecycle_environment.must_equal(@env)
      host.content_facet.content_view.must_equal(@cv)
      host.content_source.must_equal(@content_source)
      host.architecture.must_equal(@arch)
    end
    options = kickstart_repository_options(nil)
    refute_empty options
    assert_equal ret.first[:name], options.first.name
  end

  test "kickstart_repository_options should provide options for a populated host" do
    host = ::Host.new(:architecture => @arch, :operatingsystem => @os,
                      :content_facet_attributes => {:lifecycle_environment_id => @env.id,
                                                    :content_view_id => @cv.id})
    host.content_source = @content_source
    ret = [{:name => "boo" }]

    @os.expects(:kickstart_repos).returns(ret).with do |param_host|
      param_host.must_be_kind_of(::Host::Managed)
      param_host.os.must_equal(@os)
      param_host.content_facet.lifecycle_environment.must_equal(@env)
      param_host.content_facet.content_view.must_equal(@cv)
      param_host.content_source.must_equal(@content_source)
      param_host.architecture.must_equal(@arch)
    end

    options = kickstart_repository_options(host)
    refute_empty options
    assert_equal ret.first[:name], options.first.name
  end

  test "kickstart_repository_options should provide options for a populated hostgroup" do
    self.params = {}
    hostgroup = ::Hostgroup.new(:lifecycle_environment_id => @env.id,
                                :content_view_id => @cv.id)
    hostgroup.architecture = @arch
    hostgroup.operatingsystem = @os
    hostgroup.content_source = @content_source
    ret = [{:name => "boo" }]

    @os.expects(:kickstart_repos).returns(ret).with do |param_host|
      param_host.must_be_kind_of(::Host::Managed)
      param_host.os.must_equal(@os)
      param_host.content_facet.lifecycle_environment.must_equal(@env)
      param_host.content_facet.content_view.must_equal(@cv)
      param_host.content_source.must_equal(@content_source)
      param_host.architecture.must_equal(@arch)
    end

    options = kickstart_repository_options(hostgroup)
    refute_empty options
    assert_equal ret.first[:name], options.first.name
  end

  test "kickstart_repository_options should provide options for a populated host with a selected_host_group" do
    host = ::Host.new
    hostgroup = ::Hostgroup.new(:lifecycle_environment_id => @env.id,
                                :content_view_id => @cv.id)
    hostgroup.architecture = @arch
    hostgroup.operatingsystem = @os
    hostgroup.content_source = @content_source

    ret = [{:name => "boo" }]

    @os.expects(:kickstart_repos).returns(ret).with do |param_host|
      param_host.must_be_kind_of(::Host::Managed)
      param_host.os.must_equal(@os)
      param_host.content_facet.lifecycle_environment.must_equal(@env)
      param_host.content_facet.content_view.must_equal(@cv)
      param_host.content_source.must_equal(@content_source)
      param_host.architecture.must_equal(@arch)
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
    @content_source = SmartProxy.create!(:name => "foobar", :url => "http://capsule.com/")
    @arch = architectures(:x86_64)
    @cv = @repo_with_distro.content_view
    @env  = @repo_with_distro.environment
    @hostgroup = ::Hostgroup.new(:lifecycle_environment_id => @env.id,
                                :content_view_id => @cv.id)
    @hostgroup.architecture = @arch
    @hostgroup.operatingsystem = @os
    @hostgroup.content_source = @content_source

    @host = ::Host.new(:architecture => @arch, :operatingsystem => @os,
                      :content_facet_attributes => {:lifecycle_environment_id => @env.id,
                                                    :content_view_id => @cv.id})
    @host.content_source = @content_source
  end

  test "must return host or host group kickstart id" do
    repo_id = 1000
    @hostgroup.kickstart_repository_id = repo_id
    assert_equal repo_id, kickstart_repository_id(@hostgroup)
    @host.kickstart_repository_id = repo_id
    assert_equal repo_id, kickstart_repository_id(@host)
  end

  test "must handle  hosts or  host groups with medium_id but no kickstart_repository_id" do
    @hostgroup.kickstart_repository_id = nil
    @hostgroup.medium_id = 1000
    assert_nil kickstart_repository_id(@hostgroup)

    @host.kickstart_repository_id = nil
    @host.medium_id = 1000
    assert_nil kickstart_repository_id(@host)
  end

  test "must handle hosts or host groups with no medium_id or kickstart_repository_id" do
    id = 100
    option = mock
    option.expects(:id).returns(id).at_least_once
    @hostgroup.kickstart_repository_id = nil
    @hostgroup.medium_id = nil
    expects(:kickstart_repository_options).with(@hostgroup, {}).returns([option])
    assert_equal id, kickstart_repository_id(@hostgroup)

    @host.kickstart_repository_id = nil
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
    @hostgroup.kickstart_repository_id = id
    host = ::Host.new
    expects(:kickstart_repository_options).at_least_once.
      returns([OpenStruct.new(:id => id)])

    assert_equal id, kickstart_repository_id(host, :selected_host_group => @hostgroup)

    #if the host group had a medium_id lets make sure that gets used.
    @hostgroup.kickstart_repository_id = nil
    @hostgroup.medium_id = id
    assert_nil kickstart_repository_id(::Host.new, :selected_host_group => @hostgroup)
  end
end
