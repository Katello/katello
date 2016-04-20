require 'katello_test_helper'

module Katello
  class MediumExtensionsTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      @repo_without_distro = Repository.find(katello_repositories(:feedless_fedora_17_x86_64).id)
      @distro = OpenStruct.new(:name => 'RedHat', :family => @repo.distribution_family,
                               :version => @repo.distribution_version,
                               :arch => @repo.distribution_arch)
      @medium_name = Medium.construct_name(@repo, @distro)

      Repository.any_instance.stubs(:uri).returns('http://test_uri/')
      Repository.any_instance.stubs(:bootable_distribution).returns(@distro)
      Repository.any_instance.stubs(:puppet?).returns(false)
    end

    def test_update_media_with_distro
      assert_nil Operatingsystem.where(:name => @distro.name).first
      assert_nil Medium.where(:name => @medium_name).first

      Medium.update_media(@repo)

      refute_nil Operatingsystem.where(:name => @distro.name).first
      refute_nil Architecture.where(:name => @distro.arch).first
      refute_nil Medium.where(:name => @medium_name).first
    end

    def test_update_media_without_distro
      Repository.any_instance.stubs(:bootable_distribution).returns(nil)

      Medium.update_media(@repo_without_distro)
      assert_nil Medium.where(:name => @medium_name).first
    end

    def test_normalize_name
      name = Medium.normalize_name('Red_Hat_Enterprise_Linux_6_Server')
      assert_equal name, 'Red_Hat_6_Server'

      name = Medium.normalize_name('MyLinux OS')
      assert_equal name, 'MyLinux OS'
    end

    def test_installation_media_path
      path = Medium.installation_media_path('https://my_distro.com/repos')
      assert_equal path, 'http://my_distro.com/repos/'

      path = Medium.installation_media_path('http://my_distro.com/repos/')
      assert_equal path, 'http://my_distro.com/repos/'
    end
  end
end
