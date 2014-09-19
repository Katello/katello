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
  class HostManagedExtensionsTest < ActiveSupport::TestCase

    def self.before_suite
      services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
      models    = ['User', 'KTEnvironment', 'Organization',
                   "ContentView", "System"]
      disable_glue_layers(services, models)

      configure_runcible
    end

    def setup
      disable_orchestration # disable foreman orchestration

      content_host = Katello::System.find(katello_systems(:simple_server))
      @foreman_host = Host.find(hosts(:one))
      @foreman_host.puppetclasses = []
      @foreman_host.content_host = content_host
      @foreman_host.save!

      new_puppet_environment = Environment.find(environments(:testing))

      @foreman_host.environment = new_puppet_environment
    end

    def teardown
      @foreman_host.content_host.destroy
      @foreman_host.reload.destroy
    end

    def test_update_puppet_environment_updates_content_host
      Environment.any_instance.stubs(:content_view_puppet_environment).returns(
          ContentViewPuppetEnvironment.find(katello_content_view_puppet_environments(:dev_view_puppet_environment)))

      # we are making an update to the foreman host that should result in a change to the content host
      @foreman_host.content_host.expects(:save!)
      @foreman_host.save!
    end

    def test_update_puppet_environment_does_not_update_content_host
      # we are making an update to the foreman host that should NOT result in a change to the content host.
      # this can happen if the user is only using puppet environments that they create within foreman
      # vs those that automatically created as part of the katello content management
      @foreman_host.content_host.expects(:save!).never
      @foreman_host.save!
    end

    def test_update_does_not_update_content_host
      content_host = System.find(katello_systems(:simple_server2))
      @foreman_host2 = Host.find(hosts(:two))
      @foreman_host2.content_host = content_host
      @foreman_host2.save!

      @foreman_host2.expects(:update_content_host).never
      @foreman_host2.save!
    end

  end
end
