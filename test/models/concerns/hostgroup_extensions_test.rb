require 'katello_test_helper'
require 'support/host_support'

module Katello
  class HostgroupExtensionsTest < ActiveSupport::TestCase
    def setup
      @view = ContentView.find(katello_content_views(:library_dev_staging_view).id)
      @library = KTEnvironment.find(katello_environments(:library).id)
      @dev = KTEnvironment.find(katello_environments(:dev).id)

      @root = ::Hostgroup.create!(:name => 'AHostgroup')
      @child = ::Hostgroup.create!(:name => 'AChild', :parent => @root)
      @puppet_env = smart_proxies(:puppetmaster)
    end

    def test_create_with_content_source
      content_source = smart_proxies(:four)
      host_group = ::Hostgroup.new(:name => 'new_hostgroup', :content_source => content_source)
      assert_valid host_group
      assert_equal content_source, host_group.content_source
    end

    def test_update_content_source
      content_source = smart_proxies(:four)
      host_group = ::Hostgroup.create!(:name => 'new_hostgroup')
      host_group.content_source = content_source
      assert_valid host_group
      assert_equal content_source, host_group.content_source
    end

    def inherited_content_source_id_with_ancestry
      @root.content_source =
        @root.save!

      assert_equal @puppet_env, @child.content_source
      assert_equal @puppet_env, @root.content_source
    end

    def test_add_organization_for_environment
      @root.lifecycle_environment = @library
      @root.save!

      assert_includes @root.organizations, @library.organization
    end

    def test_inherited_lifecycle_environment_with_ancestry
      @root.lifecycle_environment = @library
      @root.save!

      assert_equal @library, @child.lifecycle_environment
      assert_equal @library, @root.lifecycle_environment
    end

    def test_inherited_content_view_with_ancestry
      @root.content_view = @view
      @root.save!

      assert_equal @view, @child.content_view
      assert_equal @view, @root.content_view
    end

    def test_inherited_content_view_with_ancestry_nill
      @child.content_view = @view
      @child.save!

      assert_equal @view, @child.content_view
      assert_nil @root.content_view
    end

    def test_inherited_lifecycle_environment_with_ancestry_nil
      @child.lifecycle_environment = @library
      @child.save!

      assert_equal @library, @child.lifecycle_environment
      assert_nil @root.lifecycle_environment
    end
  end

  class HostgroupExtensionsKickstartTest < ActiveSupport::TestCase
    def setup
      @distro = katello_repositories(:fedora_17_x86_64)
      @dev_distro = katello_repositories(:fedora_17_x86_64_acme_dev)
      @os = ::Redhat.create_operating_system("GreatOS", *@distro.distribution_version.split('.'))
      @no_family_os = FactoryBot.create(:operatingsystem,
                                        major: 1,
                                        name: 'no_family_os')
      @arch = architectures(:x86_64)
      @distro_cv = @distro.content_view
      @distro_env = @distro.environment
      @content_source = FactoryBot.create(:smart_proxy,
                                          name: "foobar",
                                          url: "http://example.com/",
                                          lifecycle_environments: [@distro_env, @dev_distro.environment])
      @medium = FactoryBot.create(:medium, operatingsystems: [@os])
    end

    def test_update_kickstart_repository
      hg = ::Hostgroup.create(
        name: 'kickstart_repo',
        operatingsystem: @os,
        architecture: @arch
        )
      facet = Katello::Hostgroup::ContentFacet.create!(hostgroup: hg)
      facet.content_view = @distro_cv
      facet.content_source = @content_source
      facet.lifecycle_environment = @distro_env
      facet.kickstart_repository = @distro
      assert facet.save
      assert_valid facet
      assert_equal hg.reload.kickstart_repository, @distro
    end

    def test_set_kickstart_repository
      @os.stubs(:kickstart_repos).returns([@distro])
      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        kickstart_repository: @distro)

      assert_valid hg
      assert_equal hg.kickstart_repository, @distro
    end

    def test_set_installation_medium
      hg = ::Hostgroup.new(
        name: 'install_media',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        medium: @medium)

      assert_valid hg
      assert_equal hg.medium, @medium
    end

    def test_change_medium_to_kickstart_repository
      @os.stubs(:kickstart_repos).returns([@distro])
      hg = ::Hostgroup.new(
        name: 'install_media',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        medium: @medium)

      assert hg.save
      hg.kickstart_repository = @distro
      assert_valid hg
      assert_nil hg.medium
      assert_equal hg.kickstart_repository, @distro
    end

    def test_change_kickstart_repository_to_medium
      @os.stubs(:kickstart_repos).returns([@distro])
      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        kickstart_repository: @distro)

      assert hg.save
      hg.medium = @medium
      assert_valid hg
      assert_nil hg.kickstart_repository
      assert_equal hg.medium, @medium
    end

    def test_change_lifecycle_environment_mismatched_kickstart
      @os = ::Redhat.create_operating_system("GreatOS1", *@dev_distro.distribution_version.split('.'))

      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        kickstart_repository: @distro)

      # changing the lifecycle environment will trigger
      # code which attempts to reassign the kickstart repo by its label
      hg.lifecycle_environment = @dev_distro.environment
      assert hg.save
      assert_equal hg.kickstart_repository_id, @dev_distro.id
    end

    def test_create_hostgroup_no_family_os
      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @no_family_os)

      assert_valid hg
    end
  end
end
