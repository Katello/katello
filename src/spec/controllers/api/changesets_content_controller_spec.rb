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


describe Api::ChangesetsContentController do
  include LoginHelperMethods

  let(:changeset_id) { 1 }
  let(:product_cp_id) { 123456 }
  let(:package_name) { "package-123" }
  let(:erratum_id) {"erratum-123"}
  let(:repo_id) {2}
  let(:template_id) {3}
  let(:distribution_id) {4}

  before(:each) do
    @locker = KTEnvironment.new(:name => 'Locker', :locker => true)
    @locker.id = 2
    @locker.stub(:locker?).and_return(true)
    @environment = KTEnvironment.new(:name => 'environment', :locker => false)
    @environment.id = 1
    @environment.stub(:locker?).and_return(false)
    @environment.stub(:prior).and_return(@locker)
    @locker.stub(:successor).and_return(@environment)

    @template = mock(SystemTemplate, {"name" => "tpl"})
    @product = mock(Product, {"name" => "prod"})
    @repo = mock(Product, {"name" => "repo"})

    @cs = Changeset.new(:name => "changeset", :environment => @environment, :id => changeset_id)
    Changeset.stub(:find).and_return(@cs)

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end




  describe "update products" do

    it "should add a product" do
      @cs.should_receive(:add_product).with(product_cp_id).and_return(@product)

      post :add_product, :changeset_id => changeset_id, :product_id => product_cp_id
      response.should be_success
    end

    it "should remove a product" do
      @cs.should_receive(:remove_product).with(product_cp_id).and_return(true)

      delete :remove_product, :changeset_id => changeset_id, :id => product_cp_id
      response.should be_success
    end

  end


  describe "update packages" do

    it "should add a package" do
      @cs.should_receive(:add_package).with(package_name, product_cp_id).and_return(true)

      post :add_package, :changeset_id => changeset_id, :name => package_name, :product_id => product_cp_id
      response.should be_success
    end

    it "should remove a package" do
      @cs.should_receive(:remove_package).with(package_name, product_cp_id).and_return(true)

      delete :remove_package, :changeset_id => changeset_id, :id => package_name, :product_id => product_cp_id
      response.should be_success
    end

  end


  describe "update errata" do

    it "should add an erratum" do
      @cs.should_receive(:add_erratum).with(erratum_id, product_cp_id).and_return(true)

      post :add_erratum, :changeset_id => changeset_id, :erratum_id => erratum_id, :product_id => product_cp_id
      response.should be_success
    end

    it "should remove an erratum" do
      @cs.should_receive(:remove_erratum).with(erratum_id, product_cp_id).and_return(true)

      delete :remove_erratum, :changeset_id => changeset_id, :id => erratum_id, :product_id => product_cp_id
      response.should be_success
    end

  end


  describe "update repos" do

    it "should add a repo" do
      @cs.should_receive(:add_repo).with(repo_id, product_cp_id).and_return(@repo)

      post :add_repo, :changeset_id => changeset_id, :repository_id => repo_id, :product_id => product_cp_id
      response.should be_success
    end

    it "should remove a repo" do
      @cs.should_receive(:remove_repo).with(repo_id, product_cp_id).and_return(true)

      delete :remove_repo, :changeset_id => changeset_id, :id => repo_id, :product_id => product_cp_id
      response.should be_success
    end

  end


  describe "update templates" do

    it "should add a template" do
      @cs.should_receive(:add_template).with(template_id).and_return(@template)

      post :add_template, :changeset_id => changeset_id, :template_id => template_id
      response.should be_success
    end

    it "should remove a template" do
      @cs.should_receive(:remove_template).with(template_id).and_return(true)

      delete :remove_template, :changeset_id => changeset_id, :id => template_id
      response.should be_success
    end

  end

  describe "update distributions" do

    it "should add a distribution" do
      @cs.should_receive(:add_distribution).with(distribution_id, product_cp_id).and_return(true)

      post :add_distribution, :changeset_id => changeset_id, :distribution_id => distribution_id, :product_id => product_cp_id
      response.should be_success
    end

    it "should remove a distribution" do
      @cs.should_receive(:remove_distribution).with(distribution_id, product_cp_id).and_return(true)

      delete :remove_distribution, :changeset_id => changeset_id, :id => distribution_id, :product_id => product_cp_id
      response.should be_success
    end

  end






end
