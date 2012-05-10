#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper.rb'


#def self.it_should_require_admin_for_actions(*actions)
#  actions.each do |action|
#    it "#{action} action should require admin" do
#      get action, :id => 1
#      response.should redirect_to(login_url)
#      flash[:error].should == "Unauthorized Access"
#    end
#  end
#end


describe Api::ChangesetsContentController, :katello => true do
  include LoginHelperMethods
  include AuthorizationHelperMethods

  let(:changeset_id) { 1 }
  let(:product_cp_id) { 123456 }
  let(:package_name) { "package-123" }
  let(:erratum_id) { "erratum-123" }
  let(:repo_id) { 2 }
  let(:template_id) { 3 }
  let(:distribution_id) { 4 }

  before(:each) do
    @library    = KTEnvironment.new(:name => 'Library', :library => true)
    @library.id = 2
    @library.stub(:library?).and_return(true)
    @environment    = KTEnvironment.new(:name => 'environment', :library => false)
    @environment.id = 1
    @environment.stub(:library?).and_return(false)
    @environment.stub(:prior).and_return(@library)
    @library.stub(:successor).and_return(@environment)

    @template = mock(SystemTemplate, { "name" => "tpl" })
    @product  = mock(Product, { "name" => "prod", 'id' => 0 })
    @repo     = mock(Product, { "name" => "repo" })

    @cs = Changeset.new(:name => "changeset", :environment => @environment, :id => changeset_id)
    Changeset.stub(:find_by_id).and_return(@cs)

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  let(:authorized_user) do
    user_with_permissions { |u| u.can(:manage_changesets, :environments, @environment.id, @organization) }
  end
  let(:unauthorized_user) do
    user_without_permissions
  end

  describe "products" do
    let(:action) { :add_product }
    let(:req) { post :add_product, :changeset_id => changeset_id, :product_id => product_cp_id }
    it_should_behave_like "protected action"

    it "should add a product" do
      Product.should_receive(:find_by_cp_id!).with(product_cp_id).and_return(@product)
      @cs.should_receive(:add_product!).with(@product).and_return(@product)
      req
      response.should be_success
    end
  end

  describe "products" do
    let(:action) { :remove_product }
    let(:req) { delete :remove_product, :changeset_id => changeset_id, :id => product_cp_id }
    it_should_behave_like "protected action"

    it "should remove a product" do
      Product.should_receive(:find_by_cp_id!).with(product_cp_id).and_return(@product)
      @cs.should_receive(:remove_product!).with(@product).and_return([true])
      req
      response.should be_success
    end
  end

  describe "packages" do
    let(:action) { :add_package }
    let(:req) { post :add_package, :changeset_id => changeset_id, :name => package_name, :product_id => product_cp_id }
    it_should_behave_like "protected action"

    it "should add a package" do
      Product.should_receive(:find_by_cp_id!).with(product_cp_id).and_return(@product)
      @cs.should_receive(:add_package!).with(package_name, @product).and_return({})
      req
      response.should be_success
    end
  end

  describe "packages" do
    let(:action) { :remove_package }
    let(:req) { delete :remove_package, :changeset_id => changeset_id, :id => package_name, :product_id => product_cp_id }
    it_should_behave_like "protected action"

    it "should remove a package" do
      Product.should_receive(:find_by_cp_id!).with(product_cp_id).and_return(@product)
      @cs.should_receive(:remove_package!).with(package_name, @product).and_return({})
      req
      response.should be_success
    end
  end

  describe "erratum" do
    let(:action) { :add_erratum }
    let(:req) { post :add_erratum, :changeset_id => changeset_id, :erratum_id => erratum_id, :product_id => product_cp_id }
    it_should_behave_like "protected action"

    it "should add an erratum" do
      Product.should_receive(:find_by_cp_id!).with(product_cp_id).and_return(@product)
      @cs.should_receive(:add_erratum!).with(erratum_id, @product)
      req
      response.should be_success
    end
  end

  describe "erratum" do
    let(:action) { :remove_erratum }
    let(:req) { delete :remove_erratum, :changeset_id => changeset_id, :id => erratum_id, :product_id => product_cp_id }
    it_should_behave_like "protected action"

    it "should remove an erratum" do
      Product.should_receive(:find_by_cp_id!).with(product_cp_id).and_return(@product)
      @cs.should_receive(:remove_erratum!).with(erratum_id, @product).and_return([true])
      req
      response.should be_success
    end
  end

  describe "repos" do
    let(:action) { :add_repo }
    let(:req) { post :add_repo, :changeset_id => changeset_id, :repository_id => repo_id, :product_id => product_cp_id }
    it_should_behave_like "protected action"

    it "should add a repo" do
      Repository.should_receive(:find).with(repo_id).and_return(@repo)
      @cs.should_receive(:add_repository!).with(@repo).and_return(@repo)
      req
      response.should be_success
    end
  end

  describe "repos" do
    let(:action) { :remove_repo }
    let(:req) { delete :remove_repo, :changeset_id => changeset_id, :id => repo_id, :product_id => product_cp_id }
    it_should_behave_like "protected action"

    it "should remove a repo" do
      Repository.should_receive(:find).with(repo_id).and_return(@repo)
      @cs.should_receive(:remove_repository!).with(@repo).and_return(@repo)
      req
      response.should be_success
    end
  end

  describe "templates" do
    let(:action) { :add_template }
    let(:req) { post :add_template, :changeset_id => changeset_id, :template_id => template_id }
    it_should_behave_like "protected action"

    it "should add a template" do
      SystemTemplate.should_receive(:find).with(template_id).and_return(@template)
      @cs.should_receive(:add_template!).with(@template).and_return(@template)
      req
      response.should be_success
    end
  end

  describe "templates" do
    let(:action) { :remove_template }
    let(:req) { delete :remove_template, :changeset_id => changeset_id, :id => template_id }
    it_should_behave_like "protected action"

    it "should remove a template" do
      SystemTemplate.should_receive(:find).with(template_id).and_return(@template)
      @cs.should_receive(:remove_template!).with(@template).and_return(@template)
      req
      response.should be_success
    end
  end

  describe "distributions" do
    let(:action) { :add_distribution }
    let(:req) { post :add_distribution, :changeset_id => changeset_id, :distribution_id => distribution_id, :product_id => product_cp_id }
    it_should_behave_like "protected action"

    it "should add a distribution" do
      Product.should_receive(:find_by_cp_id!).with(product_cp_id).and_return(@product)
      @cs.should_receive(:add_distribution!).with(distribution_id, @product).and_return(@product)
      req
      response.should be_success
    end
  end

  describe "distributions" do
    let(:action) { :remove_distribution }
    let(:req) { delete :remove_distribution, :changeset_id => changeset_id, :id => distribution_id, :product_id => product_cp_id }
    it_should_behave_like "protected action"

    it "should remove a distribution" do
      Product.should_receive(:find_by_cp_id!).with(product_cp_id).and_return(@product)
      @cs.should_receive(:remove_distribution!).with(distribution_id, @product).and_return(@product)
      req
      response.should be_success
    end
  end
end
