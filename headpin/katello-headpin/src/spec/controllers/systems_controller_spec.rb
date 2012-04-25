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

describe SystemsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include OrchestrationHelper
  include AuthorizationHelperMethods

  describe "rules" do
    let(:uuid) { '1234' }
    before (:each) do
      setup_system_creation
      @environment = KTEnvironment.new(:name => 'test', :prior => @organization.library.id, :organization => @organization)
      @environment.save!
      Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Candlepin::Consumer.stub!(:update).and_return(true)
      @system = System.create!(:name=>"bar1", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
      @run_auth_action = lambda do |resource, perm|
            if :organization == resource
              user_with_permissions { |u| u.can([perm], :organizations, nil, @organization) }
            else
              user_with_permissions { |u| u.can([perm], :environments, @environment.id, @organization) }
            end
      end
    end

    [:read_systems, :register_systems, :update_systems, :delete_systems].each do |perm|
      [:environment, :organization].each do |resource|

        describe "GET index with #{perm} on #{resource} " do
          let(:action) {:items}
          let(:req) { get :items}
          let(:authorized_user) do
            @run_auth_action.call(resource, perm)
          end
          let(:unauthorized_user) do
            user_without_permissions
          end

          let(:before_success) do
            controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
              search_options[:filter][:environment_id].should include(@environment.id)
              controller.stub(:render)
            }
          end

          it_should_behave_like "protected action"
        end

        describe "GET index multiple orgs with #{perm} on #{resource}" do
          before do
            new_test_org
            @environment = KTEnvironment.new(:name => 'test2', :prior => @organization.library.id, :organization => @organization)
            @system2 = System.create!(:name=>"bar2", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
          end
          let(:action) {:items}
          let(:req) { get :items}
          let(:authorized_user) do
            @run_auth_action.call(resource, perm)
          end
          let(:unauthorized_user) do
            user_without_permissions
          end

          let(:before_success) do
            controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
              search_options[:filter][:environment_id].should include(@environment.id)
              controller.stub(:render)
            }
          end

          it_should_behave_like "protected action"
        end

        describe "show sys with #{perm} on #{resource}" do
          let(:action) {:show}
          let(:req) { get :show, :id => @system.id}
          let(:authorized_user) do
            @run_auth_action.call(resource, perm)
          end
          let(:unauthorized_user) do
            user_without_permissions
          end
          it_should_behave_like "protected action"
        end

        describe "edit sys with #{perm} on #{resource} " do
          let(:action) {:update}
          let(:req) {post :update,{ :id => @system.id, :system => { :name=> "foo" }}}
          let(:authorized_user) do
            @run_auth_action.call(resource, perm)
          end
          let(:unauthorized_user) do
            user_with_permissions { |u| u.can(:read_systems, :organizations, nil, @organization) }
          end
          it_should_behave_like "protected action"
        end if perm == :update_systems


        describe "show manageable environments with #{perm} on #{resource} " do
          let(:action) {:environments}
          let(:req) { get :environments, :id => @system.id}
          let(:authorized_user) do
            @run_auth_action.call(resource, perm)
          end
          let(:unauthorized_user) do
            user_without_permissions
          end
          it_should_behave_like "protected action"
        end
      end
    end
   end

  describe "main" do
    let(:uuid) { '1234' }

    before (:each) do
      login_user
      set_default_locale

      @organization = setup_system_creation
      @environment = KTEnvironment.new(:name => 'test', :prior => @organization.library.id, :organization => @organization)
      @environment.save!

      @env1 = KTEnvironment.new(:name => 'env1', :prior => @organization.library.id, :organization => @organization)
      @env1.save!
      @env2 = KTEnvironment.new(:name => 'env2', :prior => @env1.id, :organization => @organization)
      @env2.save!

      controller.stub!(:notice)
      controller.stub(:search_validate).and_return(false)

      Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Candlepin::Consumer.stub!(:get).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Candlepin::Consumer.stub!(:update).and_return(true)

      Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Pulp::Consumer.stub!(:update).and_return(true)
    end

    describe "viewing systems" do
      before (:each) do
        100.times{|a| System.create!(:name=>"bar#{a}", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})}
        @systems = System.select(:id).where(:environment_id => @environment.id).all.collect{|s| s.id}
      end

      it "should show the system 2 pane list" do
        get :index
        response.should be_success
        response.should render_template("index")
      end

      it "should render the first 25 systems" do
        controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, filters|
          options[:list_partial].should == "systems/list_systems"
          controller.stub(:render)
        }
        get :items
        response.should be_success
      end

      describe 'with an offset' do
        pending "should return a portion of systems" do
          controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
            options[:list_partial].should == "systems/list_systems"
            start.should == 25
            controller.stub(:render)
          }
          get :items, :offset=>25
          response.should be_success
        end
      end

      it "should throw an exception when the search parameters are invalid" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        get :items, :search => 1
        response.should_not be_success
      end

      describe 'and requesting individual data' do
        before (:each) do
          @system = System.create!(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})

          Pulp::Consumer.stub!(:installed_packages).and_return([])
        end

        it "it should show facts" do
          get :facts, :id => @system.id
          response.should be_success
          response.should render_template("facts")
        end

        it "should show subscriptions" do
          @system.stub(:facts).and_return({'cpu.cpu_socket(s)'=>"3"})
          System.stub(:find).and_return(@system)
          get :subscriptions, :id => @system.id
          response.should be_success
          response.should render_template("subscriptions")
        end

        it "should show systems by env" do
          @environment2 = KTEnvironment.new(:name => 'testenv', :prior => @organization.library.id, :organization => @organization)
          @environment2.save!
          @system2 = System.create!(:name=>"verbose2", :environment => @environment2, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})
          get :environments, :env_id => @environment2.id
          response.should be_success
        end
      end
    end

    describe 'updating a system' do
      before (:each) do
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""}, :serviceLevel => nil)
      end

      it "should update the system name" do
        put :update, { :id => @system.id, :system => { :name => "foo" }}
        response.should be_success
        assigns[:system].name.should == "foo"
      end

      it "should update the system release version" do
        put :update, { :id => @system.id, :system => { :releaseVer => "6Server" }}
        response.should be_success
        assigns[:system].releaseVer.should == "6Server"
      end

      # The params to #update_subscriptions are entirely wrong here. The only reason the test
      # used to pass was because the error handler was not passing back an error status
      it "should not update a subscription" do
        put :update_subscriptions, { :id => @system.id, :system => { :name=> "foo" }}
        response.should_not be_success
      end

      it "should throw an error with bad parameters" do
        invalid_name = " Foo   "
        put :update, { :id => @system.id, :system => { :name=> invalid_name }}
        response.should_not be_success
        System.where(:name=>invalid_name).should be_empty
      end

      it_should_behave_like "bad request"  do
        let(:req) do
          put :update, { :id => @system.id, :system => { :bad_foo => "1900", :name=> "foo" }}
        end

      end
      it_should_behave_like "bad request"  do
        let(:req) do
          put :update, { :id => @system.id, :autoheal => false, :bad_foo => "ugh"}
        end
      end

    end


    describe 'bulk deleting a system' do
      before (:each) do
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
        System.stub(:find).and_return [@system]
      end
      it "should delete the system" do
        @system.should_receive(:destroy)
        delete :bulk_destroy, { :ids => [@system.id]}
        response.should be_success
      end
    end

    describe 'delete a single system' do
      before (:each) do
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
        @id = @system.id
        System.stub(:find).and_return @system
      end
      it "should delete the system" do
        @system.should_receive(:destroy)
        delete :destroy, {:id => @id, :system =>@system}
        response.should be_success
      end
    end

    describe 'creating a system' do
      render_views

      before (:each) do
        System.stub!(:save!).and_return true

        # Stub out System.where().search_for()
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
        System.stub!(:where).and_return @system
        @system.stub!(:search_for).and_return [@system]
      end

      # GET :index should not render an env_select until the :new is called
      it "should create a system in env" do
        get :index
        response.should_not render_template(:partial=>"_env_select")

        get :new
        response.should render_template(:partial=>"_new")
        response.should render_template(:partial=>"_env_select")

        controller.should_receive(:notice)
        post :create, {:system=>{:name=>"sys1", :environment_id=>@env1.id, :sockets=>2},
                       :arch=>{:arch_id=>1},
                       :system_type=>{:virtualized=>'virtual'}}
        response.should be_success
      end

      # GET :index should render an env_select but not on the :new response
      it "should create a system in env" do
        get :environments, :env_id=>@env2.id
        response.should render_template(:partial=>"_env_select")

        # The link to :new should include env_id
        # NOTE: This can't be tested since the url is modified by javascript
        #response.should have_selector("a", :id=>'new', :href=>"#", 'data-ajax_url'=>"/headpin/systems/new?env_id=#{@env2.id}")

        get :new, {:env_id=>@env2.id}
        response.should render_template(:partial=>"_new")
        response.should_not render_template(:partial=>"_env_select")

        # The hidden env_id form field should have correct id
        response.should have_selector("input", :id=>'system_environment_id', :value=>"#{@env2.id}")

        controller.should_receive(:notice)
        post :create, {:system=>{:name=>"sys1", :environment_id=>@env2.id, :sockets=>2},
                       :arch=>{:arch_id=>1},
                       :system_type=>{:virtualized=>'virtual'}}
        response.should be_success
        response.should contain '{"no_match":true}'
      end
      it_should_behave_like "bad request"  do
        let(:req) do
          post :create, {:system=>{:bad_foo=> true,:name=>"sys1", :environment_id=>@env2.id, :sockets=>2},
                         :arch=>{:arch_id=>1},
                         :system_type=>{:virtualized=>'virtual'}}
        end
      end
    end

  end

end
