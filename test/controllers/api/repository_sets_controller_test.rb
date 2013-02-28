# encoding: utf-8
#
# Copyright 2012 Red Hat, Inc.
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

class Api::RepositorySetsControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def setup
    @org = organizations(:acme_corporation)
    @environment = environments(:library)
    @redhat_product = products(:redhat)
    @custom_product = products(:fedora)
    login_user(users(:admin))
    models = ["Organization", "KTEnvironment", "Changeset"]
    services = ["Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
  end

  test "listing repo sets should be successful" do
    Product.any_instance.stubs(:productContent).returns([])
    get :index, {:product_id => @redhat_product.cp_id, :organization_id=>@org.label}
    assert_response :success
  end

  test "enabling a reposet should call refresh_repositories" do
    pc = Candlepin::ProductContent.new(:content=>{:id=>'3'})
    Product.any_instance.stubs(:productContent).returns([pc])
    Product.any_instance.expects(:async).returns(@redhat_product)
    @redhat_product.expects(:refresh_content).with('3')

    post :enable, {:product_id => @redhat_product.cp_id, :organization_id=>@org.label, :id=>'3'}
    assert_response :success
  end

  test "enabling a reposet by name should call refresh_repositories" do
     pc = Candlepin::ProductContent.new(:content=>{:id=>'3', :name=>'foo'})
     Product.any_instance.stubs(:productContent).returns([pc])
     Product.any_instance.expects(:async).returns(@redhat_product)
     @redhat_product.expects(:refresh_content).with('3')

     post :enable, {:product_id => @redhat_product.cp_id, :organization_id=>@org.label, :id=>'foo'}
     assert_response :success
   end

  test "disabling a reposet should call disable_content" do
    pc = Candlepin::ProductContent.new(:content=>{:id=>'3'})
    Product.any_instance.stubs(:productContent).returns([pc])
    Product.any_instance.expects(:async).returns(@redhat_product)
    @redhat_product.expects(:disable_content).with('3')

    post :disable, {:product_id => @redhat_product.cp_id, :organization_id=>@org.label, :id=>'3'}
    assert_response :success
  end

  test "enabling a reposet with a nonsense id should error" do
    pc = Candlepin::ProductContent.new(:content=>{:id=>'3'})
    Product.any_instance.stubs(:productContent).returns([pc])

    post :enable, {:product_id => @redhat_product.cp_id, :organization_id=>@org.label, :id=>'55'}
    assert_response :not_found
  end

  test "enabling a reposet should error for a custom product" do
    pc = Candlepin::ProductContent.new(:content=>{:id=>'3'})
    Product.any_instance.stubs(:productContent).returns([pc])

    post :enable, {:product_id => @custom_product.cp_id, :organization_id=>@org.label, :id=>'3'}
    assert_response :error
  end

  test "disabling a reposet should error for a custom product" do
    pc = Candlepin::ProductContent.new(:content=>{:id=>'3'})
    Product.any_instance.stubs(:productContent).returns([pc])

    post :disable, {:product_id => @custom_product.cp_id, :organization_id=>@org.label, :id=>'3'}
    assert_response :error
  end

end
