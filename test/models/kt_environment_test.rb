# encoding: utf-8
#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'

class KTEnvironmentTestBase < MiniTest::Rails::ActiveSupport::TestCase

  extend ActiveRecord::TestFixtures

  fixtures :all

  def self.before_suite
    services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
    models    = ['Repository', 'KTEnvironment', 'EnvironmentProduct',
                 'ContentView', 'ContentViewEnvironment']
    disable_glue_layers(services, models, true)
  end

  def setup
    @library              = KTEnvironment.find(environments(:library).id)
    @dev                  = KTEnvironment.find(environments(:dev).id)
    @staging              = KTEnvironment.find(environments(:staging).id)
    @acme_corporation     = Organization.find(organizations(:acme_corporation).id)
  end

end


class KTEnvironmentCreateTest < KTEnvironmentTestBase

  def test_create_validate_view
    env = KTEnvironment.create(:organization=>@acme_corporation, :name=>"SomeEnv", :prior=>@library)
    refute_nil env.default_content_view
    refute_nil env.default_content_view_version
    refute_empty env.default_content_view.content_view_environments.where(:environment_id=>env.id)
  end

end
