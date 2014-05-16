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
  class Api::V2::RepositoriesBulkActionsControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["Repository", "Provider"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization
      @repositories = katello_repositories(:fedora_17_unpublished, :fedora_17_unpublished_2)
      @provider = katello_providers(:fedora_hosted)
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :update_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      User.current = User.find(users(:admin))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      models
      permissions
    end

    def test_destroy_repositories
      put :destroy_repositories, {:ids => @repositories.collect(&:id), :organization_id => @organization.id}

      assert_response :success
    end

    def test_destroy_repositories_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@sync_permission, @read_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy_repositories, allowed_perms, denied_perms) do
        put :destroy_repositories, {:ids => @repositories.collect(&:id), :organization_id => @organization.id}
      end
    end

    def test_sync
      Repository.any_instance.expects(:sync).times(@repositories.length).returns([{}])

      post :sync_repositories, {:ids => @repositories.collect(&:id), :organization_id => @organization.id}

      assert_response :success
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@destroy_permission, @read_permission, @create_permission, @update_permission]

      assert_protected_action(:sync_repositories, allowed_perms, denied_perms) do
        post :sync_repositories, {:ids => @repositories.collect(&:id), :organization_id => @organization.id}
      end
    end

  end
end
