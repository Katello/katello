# encoding: utf-8
#
# Copyright 2013 Red Hat, Inc.
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

class OrganizationTestBase < MiniTest::Rails::ActiveSupport::TestCase

  extend ActiveRecord::TestFixtures

  fixtures :all

  def self.before_suite
    services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
    models    = ['Organization', 'KTEnvironment', 'ContentView',
                 'ContentViewEnvironment']
    disable_glue_layers(services, models, true)
  end

  def setup
  end

end


class OrganizationTestCreate < OrganizationTestBase

  def test_create_validate_view
    org = Organization.create!(:name=>"TestOrg", :label=>'test_org')
    refute_nil org.library
    refute_nil org.default_content_view
    refute_nil org.library.default_content_view_version
    refute_empty org.default_content_view.content_view_environments
  end

end
