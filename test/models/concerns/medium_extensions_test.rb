# encoding: UTF-8
#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
  class MediumExtensionsTest < ActiveSupport::TestCase

    def self.before_suite
      models = ["Organization", "Repository", "User"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
    end

    def setup
      User.current = User.find(users(:admin))
      @distro = OpenStruct.new(:name => 'RedHat', :family => 'Red Hat Enterprise Linux', :version => '9.0',
                               :arch => 'custom_arch')
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64))
      @medium_name = Medium.construct_name(@repo, @distro)

      Repository.any_instance.stubs(:uri).returns('http://test_uri/')
      Repository.any_instance.stubs(:bootable_distribution).returns(@distro)
      Repository.any_instance.stubs(:puppet?).returns(false)
    end

    def test_update_media_with_distro
      assert_nil Operatingsystem.where(:name => @distro.name).first
      assert_nil Architecture.where(:name => @distro.arch).first
      assert_nil Medium.where(:name => @medium_name).first

      Medium.update_media(@repo)

      refute_nil Operatingsystem.where(:name => @distro.name).first
      refute_nil Architecture.where(:name => @distro.arch).first
      refute_nil Medium.where(:name => @medium_name).first
    end

    def test_update_media_without_distro
      Repository.any_instance.stubs(:bootable_distribution).returns(nil)

      Medium.update_media(@repo)
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
