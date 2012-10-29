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

require 'spec_helper'

describe SystemTemplatesController, :katello => true do

  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper

  describe "Controller tests" do
    before(:each) do
      set_default_locale
      login_user

      @organization = new_test_org

      @system_template_1 = SystemTemplate.create!(:name => 'template1', :environment => @organization.library)
      @system_template_2 = SystemTemplate.create!(:name => 'template2', :environment => @organization.library)
    end

    describe "GET index" do
      it "requests system template using search criteria" do
        SystemTemplate.stub_chain(:where, :limit)
        get :index
      end

      it "returns system templates" do
        controller.should_receive(:retain_search_history)
        get :index
        assigns[:templates].should include @system_template_1
        response.should render_template(:index)
        response.should be_success
      end
    end

    describe "GET download" do
      describe "with valid template id" do
        before { ::Resources::Candlepin::Owner.stub!(:get_ueber_cert).and_return({ :cert => "", :key => "" }) }
        it "sends xml export of template" do
          @system_template_1.stub(:repositories).and_return([Repository.new(:name=>"FOOREPO", :pulp_id=>"anid", :relative_path => "/foo")])
          Runcible::Extensions::Distribution.stub(:find).and_return({})
          @system_template_1.stub(:distributions).and_return([SystemTemplateDistribution.new({:distribution_pulp_id=>"FOO"})])
          SystemTemplate.stub(:find).and_return(@system_template_1)
          SystemTemplate.stub(:where).and_return([@system_template_1])
          get :download, :id => @system_template_1.id, :environment_id => @organization.library.id
          response.should be_success
        end
      end

      describe "with invalid template id" do
        it "should generate an error notice" do
          controller.should notify.error
          get :download, :id => -1, :environment_id => -1
          response.should_not be_success
        end
      end
    end

    describe "GET show" do
      describe "with valid template id" do
        it "renders a list update partial for 2 pane" do
          get :show, :id => @system_template_1.id
          response.should render_template(:partial => "common/_list_update")
          response.should be_success
        end
      end

      describe "with invalid template id" do
        it "should generate an error notice" do
          controller.should notify.error
          get :show, :id => 9999
          response.should_not be_success
        end
      end
    end

    describe "GET new" do
      it "instantiates a new key" do
        SystemTemplate.should_receive(:new)
        get :new
        response.should render_template(:partial => "_new")
        response.should be_success
      end
    end

    describe "GET edit" do
      describe "with valid templateid" do
        it "renders an edit partial for 2 pane" do
          get :edit, :id => @system_template_1.id
          response.should render_template(:partial => "_edit")
          response.should be_success
        end
      end

      describe "with invalid template id" do
        it "should generate an error notice" do
          controller.should notify.error
          get :edit, :id => 9999
          response.should_not be_success
        end
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "assigns a newly created activation_key" do
          params = {:name=>"TestTemplate", :description=>"TestDesc"}
          controller.should notify.success
          post :create, :system_template=>{:name=>params[:name], :description=>params[:description]}
          response.should be_success

          assigns[:template].name.should eq(params[:name])
          assigns[:template].description.should eq(params[:description])
          response.should be_success
        end
      end

      describe "with invalid params" do
        it "should generate an error notice" do
          controller.should notify.exception
          post :create, :template => {}
          response.should_not be_success
        end
        it_should_behave_like "bad request"  do
          let(:req) do
            post :create, :system_template=>{:name=>"Guard", :bad_foo => 100,:description=>"me"}
          end
        end
      end
    end

    describe "Put update_content" do
      describe "with valid params" do

        it "should return successfully being blank" do
          controller.should notify.success
          put :update_content, :id=>@system_template_1.id, :packages=>[], :products=>[], :repos=>[], :package_groups=>[]
          response.should be_success
        end

        it "should return successfully with packages and products" do
          pkg1 = {:name=>"FOO"}
          prd1 = {:name=>"FOO", :id=>"3"}
          pkg_grp1 = {:name=>"TestGroup"}

          prod = Product.new(:environment=>Organization.first.library, :name=>"FOO")
          prod.stub(:save)
          prod.stub(:save!)
          Product.stub(:find).and_return(prod)
          Product.stub(:readable).and_return(Product)

          stp = SystemTemplatePackage.new(:system_template=>@system_template_1, :package_name=>"FOO")
          stp.stub(:valid?).and_return(true)
          SystemTemplatePackage.stub(:new).and_return(stp)

          stpg = SystemTemplatePackGroup.new(:system_template=>@system_template_1, :name=>"TestGroup")
          stpg.stub(:valid?).and_return(true)
          SystemTemplatePackGroup.stub(:new).and_return(stpg)

          controller.should notify.success
          put :update_content, :id=>@system_template_1.id, :packages=>[pkg1], :products=>[prd1], :repos=>[], :package_groups=>[pkg_grp1]
          response.should be_success

          SystemTemplate.find(@system_template_1.id).package_groups.length.should == 1
          SystemTemplate.find(@system_template_1.id).packages.length.should == 1
        end
      end
    end

    describe "PUT update" do
      describe "with valid template id" do
        describe "with valid params" do
          it "should update requested field - name" do
            controller.should notify.success
            put :update, :id => @system_template_1.id, :system_template=>{:name=>"bar"}
            assigns[:template].name.should eq("bar")
            response.should_not be_redirect
            response.should be_success
          end

          it "should update requested field - description" do
            put :update, :id => @system_template_1.id, :system_template=>{:description=>"bar"}
            assigns[:template].description.should eq("bar")
            response.should be_success
          end
        end

        describe "with invalid params" do
          it "should generate an error notice" do
            controller.should notify.exception
            put :update, :id => @system_template_1.id, :system_template=>{:name=>""}
            response.should_not be_success
          end
        end
      end

      describe "with invalid template  id" do
        it "should generate an error notice" do
          controller.should notify.error
          put :update, :id => 9999,  :system_template=>{:description=>"bar"}
          response.should_not be_success
        end

        it_should_behave_like "bad request"  do
          let(:req) do
            put :update, :id => @system_template_1.id, :system_template=>{:bad_foo=>100, :name=>"bar"}
          end
        end

      end

      describe "with template not in library" do
        before(:each) do
          @other_env = KTEnvironment.create!(:name=>"devel123", :label=> "devel123", :prior=> @organization.library, :organization=>@organization)
          @system_template_3 = SystemTemplate.create!(:name => 'template1', :environment => @other_env)

        end
        it "should generate an error notice" do
          controller.should notify.error
          put :update, :id => @system_template_3.id,  :system_template=>{:description=>"bar"}
          response.should_not be_success
        end
      end

    end

    describe "DELETE destroy" do
      describe "with valid template id" do
        before (:each) do
          controller.stub!(:render).and_return("") #ignore missing list_remove js partial
        end

        it "should delete the template" do
          controller.should notify.success
          delete :destroy, :id => @system_template_1.id
          SystemTemplate.exists?(@system_template_1.id).should be_false
          response.should be_success
        end
      end

      describe "with invalid template id" do
        it "should generate an error notice" do
          controller.should notify.error
          delete :destroy, :id => 9999
          response.should_not be_success
        end
      end
    end
  end

  describe "rules" do
    before (:each) do
      disable_user_orchestration

      @organization = new_test_org
      @testuser = User.create!(:username=>"TestUser", :password=>"foobar", :email=>"TestUser@somewhere.com")
      @system_template_1 = SystemTemplate.create!(:name => 'template1', :environment => @organization.library)
    end

    describe "GET index" do
      let(:action) {:index}
      let(:req) {get 'index' }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read_all, :system_templates, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end

      it_should_behave_like "protected action"
    end

    describe "PUT update" do
      let(:action) {:update}
      let(:req) {put 'update', {:id=> @system_template_1.id}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:manage_all, :system_templates, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read_all, :system_templates, nil, @organization) }
      end

      it_should_behave_like "protected action"
    end

    describe "PUT update_content" do
      let(:action) {:update_content}
      let(:req) {put 'update_content', {:id=> @system_template_1.id, :products=>{}, :packages=>{}}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:manage_all, :system_templates, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read_all, :system_templates, nil, @organization) }
      end

      it_should_behave_like "protected action"
    end

    describe "PUT create" do
      let(:action) {:create}
      let(:req) {post 'create', {:name=>"FOOBAR"}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:manage_all, :system_templates, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read_all, :system_templates, nil, @organization) }
      end

      it_should_behave_like "protected action"
    end

    describe "DELETE delete" do
      let(:action) {:destroy}
      let(:req) {delete 'destroy', {:id=> @system_template_1.id}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:manage_all, :system_templates, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read_all, :system_templates, nil, @organization) }
      end
      it_should_behave_like "protected action"
    end

    describe "GET object" do
      let(:action) {:object}
      let(:req) {put 'object', {:id=> @system_template_1.id}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read_all, :system_templates, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end

      it_should_behave_like "protected action"
    end
  end
end
