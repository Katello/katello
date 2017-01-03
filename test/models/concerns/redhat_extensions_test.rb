# encoding: utf-8

require 'katello_test_helper'

module Katello
  class RedhatExtensionsTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @my_distro = OpenStruct.new(:name => 'RedHat', :family => 'Red Hat Enterprise Linux', :version => '9.0')
      @repo_with_distro = katello_repositories(:fedora_17_x86_64)
    end

    def test_find_or_create_operating_system
      assert_nil ::Redhat.where(:name => @my_distro.name).first
      refute_nil ::Redhat.find_or_create_operating_system(@repo_with_distro)
    end

    def test_find_or_create_os_without_minor
      repo_without_minor = Repository.find(katello_repositories(:rhel_7_x86_64).id)
      os_count = Operatingsystem.count
      created = ::Redhat.find_or_create_operating_system(repo_without_minor)
      created2 = ::Redhat.find_or_create_operating_system(repo_without_minor)
      assert_equal created, created2
      assert_equal os_count + 1, Operatingsystem.count
    end

    def test_create_operating_system
      assert_nil ::Redhat.where(:name => @my_distro.name).first

      os = ::Redhat.create_operating_system(@my_distro.name, '9', '0')

      refute_nil os
      assert_equal os.name, @my_distro.name
      assert_equal os.major, '9'
      assert_equal os.minor, '0'
    end

    def test_construct_name
      assert_equal ::Redhat.construct_name('Red Hat Enterprise Linux'), 'RedHat'
      assert_equal ::Redhat.construct_name('My Custom Linux'), 'My_Custom_Linux'
    end

    def test_distribution_repositories
      version = @repo_with_distro.distribution_version.split('.')
      os = ::Redhat.create_operating_system(@my_distro.name, version[0], version[1])
      other_repo = katello_repositories(:fedora_17_library_library_view)
      host = ::Host.new(:architecture => architectures(:x86_64), :operatingsystem => os,
                        :content_facet_attributes => {:lifecycle_environment_id => @repo_with_distro.environment.id,
                                                      :content_view_id => @repo_with_distro.content_view.id})

      assert_equal @repo_with_distro.distribution_arch, other_repo.distribution_arch
      assert_equal @repo_with_distro.distribution_version, other_repo.distribution_version

      repo_list = os.distribution_repositories(host)
      assert_includes repo_list, @repo_with_distro
      refute_includes repo_list, other_repo
    end
  end

  class RedhatExtensionsMediaTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin))
      @repo_with_distro = katello_repositories(:fedora_17_x86_64)
      version = @repo_with_distro.distribution_version.split('.')
      @os = ::Redhat.create_operating_system("RedHat", version[0], version[1])
      @content_source = FactoryGirl.create(:smart_proxy, :name => "foobar", :url => "http://capsule.com/")

      @host = ::Host.new(:architecture => architectures(:x86_64), :operatingsystem => @os,
                        :content_facet_attributes => {:lifecycle_environment_id => @repo_with_distro.environment.id,
                                                      :content_view_id => @repo_with_distro.content_view.id,
                                                      :content_source => @content_source})

      @hostgroup = Hostgroup.new(:name => "testhg", :lifecycle_environment_id => @repo_with_distro.environment.id,
                                 :content_view_id => @repo_with_distro.content_view.id)
      @hostgroup.architecture = architectures(:x86_64)
      @hostgroup.operatingsystem = @os
      @hostgroup.content_source = @content_source
    end

    def test_medium_uri_for_no_content_source_or_ks_repo
      # create os
      @os.media.create!(:name => "my-media", :path => "http://www.foo.com/abcd")
      @host.medium = @os.media.first
      @host.content_facet.content_source = nil
      @host.content_facet.kickstart_repository = @repo_with_distro
      assert_equal @os.media.first.path, @os.medium_uri(@host).to_s

      @host.content_facet.content_source = @content_source
      @host.content_facet.kickstart_repository = nil
      assert_equal @os.media.first.path, @os.medium_uri(@host).to_s
    end

    def test_medium_uri_for_no_content_source_or_ks_repo_hg
      @os.media.create!(:name => "my-media", :path => "http://www.foo.com/abcd")
      @hostgroup.medium = @os.media.first
      @hostgroup.content_source = nil
      @hostgroup.kickstart_repository = @repo_with_distro
      assert_equal @os.media.first.path, @os.medium_uri(@hostgroup).to_s

      @hostgroup.content_source = @content_source
      @hostgroup.kickstart_repository = nil
      assert_equal @os.media.first.path, @os.medium_uri(@hostgroup).to_s
    end

    def test_medium_uri_with_a_kickstart_repo
      @host.content_facet.kickstart_repository = @repo_with_distro
      assert_equal @repo_with_distro.full_path(@content_source), @os.medium_uri(@host).to_s
    end

    def test_medium_uri_with_a_kickstart_repo_hg
      @hostgroup.kickstart_repository = @repo_with_distro
      assert_equal @repo_with_distro.full_path(@content_source), @os.medium_uri(@hostgroup).to_s
    end

    def test_kickstart_repos_with_no_content_source
      @os.expects(:distribution_repositories).with(@host).returns([@repo_with_distro])
      @host.content_facet.content_source = nil
      assert_empty @os.kickstart_repos(@host)
    end

    def test_kickstart_repos_with_one_distro
      @os.expects(:distribution_repositories).with(@host).returns([@repo_with_distro])
      repos = @os.kickstart_repos(@host)
      refute_empty repos
      assert_equal @repo_with_distro.full_path(@content_source), repos.first[:path]
    end
  end
end
