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
  class Api::V2::HostCollectionsControllerTest < ActionController::TestCase
    def self.before_suite
      models = ["System", "HostCollection"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @system = katello_systems(:simple_server)
      @host_collection = katello_host_collections(:simple_host_collection)
      @organization = get_organization

      HostCollection.stubs('any_readable?').with(@organization).returns(true)
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
      @fake_search_service.stubs(:retrieve).returns([[@host_collection], 1])
      @fake_search_service.stubs(:total_items).returns(1)

      results = JSON.parse(get(:index, :organization_id => @organization.id).body)

      assert_response :success
      assert_template 'api/v2/host_collections/index'

      assert_equal results.keys.sort, ['page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 1
      assert_equal results['results'][0]['id'], @host_collection.id
    end

    def test_show
      results = JSON.parse(get(:show, :id => @host_collection.id).body)

      assert_equal results['name'], 'Simple Host Collection'

      assert_response :success
      assert_template 'api/v2/host_collections/show'
    end

    def test_create
      post :create, :organization_id => @organization,
                    :host_collection => {:name => 'Collection A', :description => 'Collection A, World Cup 2014',
                                         :system_ids => [@system.id]}

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Collection A'
      assert_equal results['unlimited_content_hosts'], true
      assert_equal results['organization_id'], @organization.id
      assert_equal results['description'], 'Collection A, World Cup 2014'
      assert_equal results['system_ids'], [@system.id]

      assert_response :success
      assert_template 'api/v2/host_collections/create'
    end

    def test_create_with_system_uuid
      post :create, :organization_id => @organization, :system_uuids => [@system.uuid],
        :host_collection => {:name => 'Collection A', :description => 'Collection A, World Cup 2014'}

      results = JSON.parse(response.body)
      assert_equal results['system_ids'], [@system.id]

      assert_response :success
      assert_template 'api/v2/host_collections/create'
    end
  end
end
