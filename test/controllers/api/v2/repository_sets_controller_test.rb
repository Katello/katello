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
class Api::V2::RepositorySetsControllerTest < ActionController::TestCase

  include Support::ForemanTasks::Task

  def models
    @organization = get_organization
    @product = katello_products(:redhat)
  end

  def setup
    setup_controller_defaults_api
    login_user(User.find(users(:admin)))
    User.current = User.find(users(:admin))
    @request.env['HTTP_ACCEPT'] = 'application/json'
    @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
    models
    @content = OpenStruct.new(id: 'content-123')
    Product.any_instance.stubs(productContent: [OpenStruct.new(content: @content)])

  end

  def test_available_repositories
    task = assert_sync_task ::Actions::Katello::RepositorySet::ScanCdn do |product, content_id|
      product.must_equal @product
      content_id.must_equal @content.id
    end
    task.expects(:output).at_least_once.returns(results: [])

    get :available_repositories, product_id: @product.id, id: @content.id
    assert_response :success
  end

  def test_repository_enable
    assert_sync_task ::Actions::Katello::RepositorySet::EnableRepository do |product, content, substitutions|
      product.must_equal @product
      content.id.must_equal @content.id
      substitutions.must_equal('basearch' => 'x86_64', 'releasever' => '6Server')
    end

    put :enable,
        product_id: @product.id,
        id: @content.id,
        basearch: 'x86_64', releasever: '6Server'
    assert_response :success
  end

  def test_repository_disable
    assert_sync_task ::Actions::Katello::RepositorySet::DisableRepository do |product, content, substitutions|
      product.must_equal @product
      content.id.must_equal @content.id
      substitutions.must_equal('basearch' => 'x86_64', 'releasever' => '6Server')
    end

    put :disable,
        product_id: @product.id,
        id: @content.id,
        basearch: 'x86_64', releasever: '6Server'
    assert_response :success
  end

end
end
