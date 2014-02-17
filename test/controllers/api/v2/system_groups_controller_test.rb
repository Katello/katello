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

require "katello_test_helper"

module Katello
  class Api::V2::SystemGroupsControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["System", "SystemGroup"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @system = katello_systems(:simple_server)
      @system_group = katello_system_groups(:simple_group)
      @organization = get_organization

      SystemGroup.stubs('any_readable?').with(@organization).returns(true)
      stub_find_organization(@organization)
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)

      models
    end

    def test_index
      @fake_search_service.stubs(:retrieve).returns([[@system_group], 1])
      @fake_search_service.stubs(:total_items).returns(1)

      results = JSON.parse(get(:index, :organization_id => @organization.id).body)

      assert_response :success
      assert_template 'api/v2/system_groups/index'

      assert_equal results.keys.sort, ['page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 1
      assert_equal results['results'][0]['id'], @system_group.id
    end

    def test_show
      results = JSON.parse(get(:show, :id => @system_group.id).body)

      assert_equal results['name'], 'Simple Group'

      assert_response :success
      assert_template 'api/v2/system_groups/show'
    end

    def test_create
      post :create, :organization_id => @organization,
        :system_group => {:name => 'Group A', :description => 'Group A, World Cup 2014'}

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Group A'
      assert_equal results['max_systems'], -1
      assert_equal results['organization_id'], @organization.id
      assert_equal results['description'], 'Group A, World Cup 2014'

      assert_response :success
      assert_template 'api/v2/system_groups/create'
    end

  end
end
