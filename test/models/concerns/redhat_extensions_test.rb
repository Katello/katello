# encoding: utf-8

require 'katello_test_helper'

module Katello
  class RedhatExtensionsTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin))
      @my_distro = OpenStruct.new(:name => 'RedHat', :family => 'Red Hat Enterprise Linux', :version => '9.0')
      @repo_with_distro = Repository.find(katello_repositories(:fedora_17_x86_64))
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
  end
end
