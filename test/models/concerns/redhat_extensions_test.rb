# encoding: utf-8

require 'katello_test_helper'

module Katello
  class RedhatExtensionsTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin))
      @my_distro = OpenStruct.new(:name => 'RedHat', :family => 'Red Hat Enterprise Linux', :version => '9.0')
      @repo_with_distro = katello_repositories(:fedora_17_x86_64)
    end

    def test_find_or_create_operating_system
      assert_nil ::Redhat.where(:name => @my_distro.name).first
      refute_nil ::Redhat.find_or_create_operating_system(@repo_with_distro)
    end

    def test_find_or_create_os_without_minor
      repo_without_minor = Repository.find(katello_repositories(:rhel_7_x86_64))
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
end
