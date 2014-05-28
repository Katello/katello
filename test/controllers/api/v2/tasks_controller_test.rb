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
class Api::V2::TasksControllerTest < ActionController::TestCase

  def before_suite
    models = []
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
    super
  end

  def models
    @organization = get_organization
  end

  def setup
    setup_controller_defaults_api
    @request.env['HTTP_ACCEPT'] = 'application/json'
    @request.env['CONTENT_TYPE'] = 'application/json'
    @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
    models
  end

  def test_index
    get :index, :organization_id => @organization.id

    assert_response :success
    assert_template %w(katello/api/v2/tasks/index)
  end

  def test_index_protected
    assert_protected_action(:index, :view_organizations) do
      get :index, :organization_id => @organization.id
    end
  end

  def test_show
    TaskStatus.stubs(:find_by_id!).returns(TaskStatus.new(:organization => @organization, :user => User.current))
    get :show, :id => '1'

    assert_response :success
    assert_template %w(katello/api/v2/packages/show)
  end

  def test_show_protected
    TaskStatus.stubs(:find_by_id!).returns(TaskStatus.new(:organization => @organization))
    get :show, :id => '1'

    assert_response 403
  end

end
end
