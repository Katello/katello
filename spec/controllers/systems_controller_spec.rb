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
  include AuthorizationHelperMethods

  describe "rules" do
    let(:uuid) { '1234' }
    before (:each) do
      setup_system_creation
      @environment = KTEnvironment.new(:name => 'test', :prior => @organization.locker.id, :organization => @organization)
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

    [:read_systems, :create_systems, :update_systems, :delete_systems].each do |perm|
      [:environment, :organization].each do |resource|

        describe "GET index with #{perm} on #{resource} " do
          let(:action) {:index}
          let(:req) { get :index}
          let(:authorized_user) do
            @run_auth_action.call(resource, perm)
          end
          let(:unauthorized_user) do
            user_without_permissions
          end
          let(:on_success) do
            assigns[:systems].should include @system
          end
          it_should_behave_like "protected action"
        end

        describe "GET index multiple orgs with #{perm} on #{resource}" do
          before do
            new_test_org
            @environment = KTEnvironment.new(:name => 'test2', :prior => @organization.locker.id, :organization => @organization)
            @system2 = System.create!(:name=>"bar2", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
          end
          let(:action) {:index}
          let(:req) { get :index}
          let(:authorized_user) do
            @run_auth_action.call(resource, perm)
          end
          let(:unauthorized_user) do
            user_without_permissions
          end
          let(:on_success) do
            assigns[:systems].should include @system2
            assigns[:systems].should_not include @system
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
      end if [:create_systems, :update_systems].include? perm


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
      @environment = KTEnvironment.new(:name => 'test', :prior => @organization.locker.id, :organization => @organization)
      @environment.save!

      controller.stub!(:errors)
      controller.stub!(:notice)

      Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Candlepin::Consumer.stub!(:update).and_return(true)

      Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Pulp::Consumer.stub!(:update).and_return(true)
    end

    describe "viewing systems" do
      before (:each) do
        100.times{|a| System.create!(:name=>"bar#{a}", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})}
      end

      it "should show the system 2 pane list" do
        get :index
        response.should be_success
        response.should render_template("index")
        assigns[:systems].should include System.find(8)
        assigns[:systems].should_not include System.find(30)
      end

      it "should return a portion of systems" do
        get :items, :offset=>25
        response.should be_success
        response.should render_template("list_systems")
        assigns[:systems].should include System.find(30)
        assigns[:systems].should_not include System.find(8)
      end

      it "should throw an exception when the search parameters are invalid" do
        controller.should_receive(:errors)
        get :index, :search => 1
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
          get :subscriptions, :id => @system.id
          response.should be_success
          response.should render_template("subscriptions")
        end

        it "should show packages" do
          get :packages, :id => @system.id
          response.should be_success
          response.should render_template("packages")
        end

        it "should show systems by env" do
          @environment2 = KTEnvironment.new(:name => 'testenv', :prior => @organization.locker.id, :organization => @organization)
          @environment2.save!
          @system2 = System.create!(:name=>"verbose", :environment => @environment2, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})
          get :environments, :env_id => @environment2.id
          assigns[:systems].should include System.find(@system2.id)
          response.should be_success
        end
      end
    end

    describe 'updating a system' do
      before (:each) do
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
      end

      it "should update the system name" do
        put :update, { :id => 1, :system => { :name=> "foo" }}
        response.should be_success
        assigns[:system].name.should == "foo"
      end

      it "should update a subscription" do
        put :update_subscriptions, { :id => 1, :system => { :name=> "foo" }}
        response.should be_success
      end

      it "should throw an error with bad parameters" do
        put :update, { :id => 1, :system => { :name=> 1 }}
        response.should_not be_success
        System.where(:name=>1).should be_empty
      end
    end

  end

end
