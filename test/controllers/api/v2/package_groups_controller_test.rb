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
class Api::V2::PackageGroupsControllerTest < ActionController::TestCase

  def before_suite
    models = ["Organization", "LifecycleEnvironment", "PackageGroup", "Repository", "Product", "Provider"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
    super
  end

  def models
    @repo = Repository.find(katello_repositories(:fedora_17_x86_64_dev))
  end

  def permissions
    @env_read_permission = UserPermission.new(:read_contents, :environments)
    @prod_read_permission = UserPermission.new(:read, :providers)
    @read_permission = @env_read_permission + @prod_read_permission
    @unauth_perms = [NO_PERMISSION, @env_read_permission, @prod_read_permission]
  end

  def setup
    setup_controller_defaults_api
    @request.env['HTTP_ACCEPT'] = 'application/json'
    @request.env['CONTENT_TYPE'] = 'application/json'
    @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
    models
    permissions
  end

  def test_index
    get :index, :repository_id => @repo.id

    assert_response :success
    assert_template %w(katello/api/v2/package_groups/index)
  end

  def test_index_protected
    assert_protected_action(:index, @read_permission, @unauth_perms) do
      get :index, :repository_id => @repo.id
    end
  end

  def test_show
    PackageGroup.expects(:find).once.returns(mock({}))
    get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"

    assert_response :success
    assert_template %w(katello/api/v2/package_groups/show)
  end

  def test_show_group_not_found
    PackageGroup.expects(:find).once.returns(nil)
    get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"
    assert_response 404
  end

  def test_show_protected
    PackageGroup.expects(:find).returns(mock({}))

    assert_protected_action(:show, @read_permission, @unauth_perms) do
      get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"
    end
  end

end
end
