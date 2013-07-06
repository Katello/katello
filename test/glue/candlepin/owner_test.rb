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
require './test/support/candlepin/owner_support'


class GlueCandlepinOwnerTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend  ActiveRecord::TestFixtures

  fixtures :all

  def self.before_suite
    @loaded_fixtures = load_fixtures

    services  = ['Pulp', 'ElasticSearch', 'Foreman']
    models    = ['User', 'KTEnvironment', 'Organization']
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
    VCR.insert_cassette('glue_candlepin_owner', :match_requests_on => [:path, :params, :method, :body_json])

  end

  def self.after_suite
    true
  ensure
    VCR.eject_cassette
  end

end

class GlueCandlepinOwnerTestSLA < GlueCandlepinOwnerTestBase

  def self.before_suite
    super
    @@org = CandlepinOwnerSupport.create_organization('GlueCandlepinOwnerTestSystem_1', 'GlueCandlepinOwnerTestSystem_1')
  end

  def self.after_suite
    CandlepinOwnerSupport.destroy_organization(@@org.id)
    super
  end

  def test_update_candlepin_owner_service_level
    # Without any choices, should not be able to set a service level
    assert_equal nil, @@org.service_level
    e = assert_raises(RestClient::BadRequest) do
      @@org.service_level = 'Premium'
    end
    expected = "{\n  \"displayMessage\" : \"Service level 'Premium' is not available to consumers of organization GlueCandlepinOwnerTestSystem_1.\"\n}"
    assert_equal JSON.parse(expected), JSON.parse(e.response)
    assert_equal nil, @@org.service_level

    # Should be able to set clear the default
    @@org.service_level = ''
    assert_equal nil, @@org.service_level

    # ...with a nil too
    @@org.service_level = nil
    assert_equal nil, @@org.service_level
  end

end
