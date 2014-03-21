# encoding: utf-8
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

require "katello_test_helper"

module Katello
  class Api::V2::OrganizationsControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["Organization"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'

      models
    end

    def test_index
      results = JSON.parse(get(:index).body)

      assert_response :success
      assert_template 'api/v2/organizations/index'

      assert_equal results.keys.sort, ['page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
    end

    def test_show
      results = JSON.parse(get(:show, :id => @organization.id).body)

      assert_equal results['name'], @organization.name

      assert_response :success
      assert_template 'api/v2/organizations/show'
    end

  end
end
