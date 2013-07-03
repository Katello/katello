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

require "minitest_helper"

class ProductsControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def setup
    @org = organizations(:acme_corporation)
    @environment = environments(:library)
    @redhat_product = products(:redhat)
    @custom_product = products(:fedora)
    login_user(User.find(users(:admin)), @org)
    models = ["Organization", "KTEnvironment"]
    services = ["Pulp", "ElasticSearch", "Foreman", "Candlepin"]
    disable_glue_layers(services, models)

    @pc = Candlepin::ProductContent.new({:content=>{:id=>'3'}}, @redhat_product.id)
    Product.any_instance.stubs(:productContent).returns([@pc])
  end

  test "enabling a reposet should call refresh_repositories" do
    Product.stubs(:find).returns(@redhat_product)
    @redhat_product.expects(:refresh_content).with('3').returns(@pc)

    put :refresh_content, {:id => @redhat_product.id,  :content_id=>'3'}
    assert_response :success
  end


  test "disabling a reposet should call disable_content" do
    Product.stubs(:find).returns(@redhat_product)
    @redhat_product.expects(:disable_content).with('3').returns(@pc)

    put :disable_content, {:id => @redhat_product.id,  :content_id=>'3'}
    assert_response :success
  end

  test "enabling a reposet should error for a custom product" do
    Product.stubs(:find).returns(@custom_product)
    @redhat_product.stubs(:refresh_content).with('3').returns(@pc)

    put :refresh_content, {:id => @custom_product.id,  :content_id=>'3'}
    assert_response :bad_request
  end


  test "disabling a reposet should call disable_content" do
    Product.stubs(:find).returns(@custom_product)
    @redhat_product.stubs(:disable_content).with('3').returns(@pc)

    put :disable_content, {:id => @custom_product.id,  :content_id=>'3'}
    assert_response :bad_request
  end


end
