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
      @environment = KTEnvironment.new(:name=>'test', :label=> 'test', :prior => @organization.library.id, :organization => @organization)
      @environment.save!
      Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stub!(:update).and_return(true)
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
            @environment = KTEnvironment.new(:name=>'test2', :label=> 'test2', :prior => @organization.library.id, :organization => @organization)
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
      @user = login_user
      set_default_locale

      @organization = setup_system_creation
      @environment = KTEnvironment.new(:name=>'test', :label=> 'test', :prior => @organization.library.id, :organization => @organization)
      @environment.save!

      @env1 = KTEnvironment.new(:name=>'env1', :label=> 'env1', :prior => @organization.library.id, :organization => @organization)
      @env1.save!
      @env2 = KTEnvironment.new(:name=>'env2', :label=> 'env2', :prior => @env1.id, :organization => @organization)
      @env2.save!

      controller.stub(:search_validate).and_return(false)

      Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stub!(:get).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stub!(:update).and_return(true)

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
        controller.should notify.exception
        get :items, :search => 1
        response.should_not be_success
      end

      describe 'and requesting individual data' do
        before (:each) do
          @system = System.create!(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})

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
          @environment2 = KTEnvironment.new(:name=>'testenv', :label=> 'testenv', :prior => @organization.library.id, :organization => @organization)
          @environment2.save!
          @system2 = System.create!(:name=>"verbose2", :environment => @environment2, :cp_type=>"system", :facts => {"Test1"=>1 , "verbose_facts" => "Test facts"})
          get :environments, :env_id => @environment2.id
          response.should be_success
        end

        describe 'listing products' do

          let(:products_count) { 7 }

          before (:each) do
            @system.installedProducts = []
            product = {"productId"=>"155", "version"=>nil, "id"=>"ff8080813990a0eb0139a0be9225006a",
                "updated"=>"2012-09-07T12:40:07.461+0000", "arch"=>nil, "status"=>nil, "created"=>"2012-09-07T12:40:07.461+0000",
                "startDate"=>nil, "endDate"=>nil}
            products_count.times do |i|
              prod = HashWithIndifferentAccess.new(product)
              prod['productName'] = "NUMBER #{i}"
              @system.installedProducts << prod
            end

            System.stub(:find).and_return(@system)
            User.stub(:current_user).and_return(@user)
          end

          [2, 3, 4, 5].each do |page_size|

            it "should show only first page" do
              @user.stub(:page_size).and_return(page_size)

              get :products, :id => @system.id
              response.should be_success
              assigns(:products_count).should == products_count
              assigns(:products).size.should == page_size

              page_size.times do |i|
                assigns(:products)[i]['productName'].should == "NUMBER #{i}"
              end
              assigns(:offset).should == page_size
            end

            it "should provide more products on demand" do
              @user.stub(:page_size).and_return(page_size)

              # how many request should be created
              requests = (products_count/page_size + (products_count%page_size == 0 ? 0 : 1)) - 1

              # each request check if it returns correct products
              (1..requests).each do |i|
                get :more_products, :id => @system.id, :offset => page_size*i
                response.should be_success
                if page_size*i+page_size > products_count
                  assigns(:products).size.should < page_size
                else
                  assigns(:products).size.should == page_size
                end
                assigns(:products).size.times do |j|
                  assigns(:products)[j]['productName'].should == "NUMBER #{j+page_size*i}"
                end
                assigns(:offset).should == page_size*(i+1)
              end

              get :more_products, :id => @system.id, :offset => page_size*(requests+1)
              response.should be_success
              assigns(:products).size.should == 0
            end
          end
        end
      end
    end

    describe 'updating a system' do
      before (:each) do
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts => { "test" => "test" }, :serviceLevel => nil)
      end

      it "should update the system name", :katello => true do #TODO headpin
        put :update, { :id => @system.id, :system => { :name => "foo" }}
        response.should be_success
        assigns[:system].name.should == "foo"
      end

      it "should update the system release version", :katello => true do #TODO headpin
        put :update, { :id => @system.id, :system => { :releaseVer => "6Server" }}
        response.should be_success
        assigns[:system].releaseVer.should == "6Server"
      end

      # The params to #update_subscriptions are entirely wrong here. The only reason the test
      # used to pass was because the error handler was not passing back an error status
      it "should not update a subscription", :katello => true do #TODO headpin
        put :update_subscriptions, { :id => @system.id, :system => { :name=> "foo" }}
        response.should_not be_success
      end

      it "should throw an error with bad parameters", :katello => true do #TODO headpin
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
      it "should delete the system", :katello => true do #TODO headpin
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

    describe "system groups" do
      before (:each) do
        @system = System.create!(:name=>"bar1", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})

        disable_consumer_group_orchestration
        @group1 = SystemGroup.create!(:name=>"test_group1", :organization=>@organization)
        @group2 = SystemGroup.create!(:name=>"test_group2", :organization=>@organization)
      end

      describe "listing/viewing" do
        it "retrieves the system groups to display", :katello => true do #TODO headpin
          SystemGroup.should_receive(:where).with(:organization_id => @organization).and_return([@group1, @group2])
          get :system_groups, :id => @system.id
        end

        it "renders the system_group partial" do
          get :system_groups, :id => @system.id
          response.should render_template(:partial => "_system_groups")
        end

        it "should be successful" do
          get :system_groups, :id => @system.id
          response.should be_success
        end
      end

      describe "add system groups" do
        it "should add the system to the groups provided", :katello => true do #TODO headpin
          assert System.find(@system.id).system_groups.size == 0
          assert SystemGroup.find(@group1.id).systems.size == 0
          assert SystemGroup.find(@group2.id).systems.size == 0
          put :add_system_groups, {:id => @system.id, :group_ids => [@group1.id, @group2.id]}
          assert System.find(@system.id).system_groups.size == 2
          assert SystemGroup.find(@group1.id).systems.size == 1
          assert SystemGroup.find(@group2.id).systems.size == 1
          response.should be_success
        end

        it "should generate a notice on success" do
          controller.should notify.success
          put :add_system_groups, {:id => @system.id, :group_ids => [@group1.id, @group2.id]}
        end

        it "should generate an error notice, if the group has reached max membership" do
          @system1 = System.create!(:name=>"system1", :environment => @environment, :cp_type=>"system", :facts=>{"Test"=>""})
          @group1.max_systems = 1
          @group1.systems << @system1
          @group1.save!
          controller.should notify.exception
          put :add_system_groups, {:id => @system.id, :group_ids => [@group1.id]}
          response.should_not be_success
        end
      end

      describe "remove system groups" do
        before (:each) do
          @system.system_groups << [@group1, @group2]
          @system.save!
        end

        it "should remove the system from the groups provided", :katello => true do #TODO headpin
          assert System.find(@system.id).system_groups.size == 2
          assert SystemGroup.find(@group1.id).systems.size == 1
          assert SystemGroup.find(@group2.id).systems.size == 1
          put :remove_system_groups, {:id => @system.id, :group_ids => [@group1.id, @group2.id]}
          assert System.find(@system.id).system_groups.size == 0
          assert SystemGroup.find(@group1.id).systems.size == 0
          assert SystemGroup.find(@group2.id).systems.size == 0
          response.should be_success
        end

        it "should generate a notice on success" do
          controller.should notify.success
          put :remove_system_groups, {:id => @system.id, :group_ids => [@group1.id]}
        end
      end
    end

    describe "bulk actions" do
      describe "add system group" do
        before (:each) do
          @system1 = System.create!(:name=>"system1", :environment => @environment, :cp_type=>"system", :facts=>{"Test"=>""})
          @system2 = System.create!(:name=>"system2", :environment => @environment, :cp_type=>"system", :facts=>{"Test"=>""})

          disable_consumer_group_orchestration
          @group1 = SystemGroup.create!(:name=>"test_group1", :organization=>@organization)
          @group2 = SystemGroup.create!(:name=>"test_group2", :organization=>@organization)
        end

        it "should add the list of systems to the groups provided", :katello => true do #TODO headpin
          assert System.find(@system1.id).system_groups.size == 0
          assert System.find(@system2.id).system_groups.size == 0
          assert SystemGroup.find(@group1.id).systems.size == 0
          assert SystemGroup.find(@group2.id).systems.size == 0
          put :bulk_add_system_group, {:ids => [@system1.id, @system2.id], :group_ids => [@group1.id, @group2.id]}
          assert System.find(@system1.id).system_groups.size == 2
          assert System.find(@system2.id).system_groups.size == 2
          assert SystemGroup.find(@group1.id).systems.size == 2
          assert SystemGroup.find(@group2.id).systems.size == 2
          response.should be_success
        end

        it "should generate a notice on success" do
          controller.should notify.success
          put :bulk_add_system_group, {:ids => [@system1.id, @system2.id], :group_ids => [@group1.id, @group2.id]}
        end

        it "should generate an error notice, if the group has reached max membership" do
          @group1.max_systems = 1
          @group1.systems << @system1
          @group1.save!
          controller.should notify.exception
          put :bulk_add_system_group, {:ids => [@system2.id], :group_ids => [@group1.id]}
          response.should_not be_success
        end
      end

      describe "remove system group" do
        before (:each) do
          @system1 = System.create!(:name=>"system1", :environment => @environment, :cp_type=>"system", :facts=>{"Test"=>""})
          @system2 = System.create!(:name=>"system2", :environment => @environment, :cp_type=>"system", :facts=>{"Test"=>""})

          disable_consumer_group_orchestration
          @group1 = SystemGroup.new(:name=>"test_group1", :organization=>@organization)
          @group1.save!
          @group1.systems << [@system1, @system2]
          @group2 = SystemGroup.new(:name=>"test_group2", :organization=>@organization)
          @group2.save!
          @group2.systems << [@system1, @system2]
        end

        it "should remove the list of systems from the groups provided", :katello => true do #TODO headpin
          assert System.find(@system1.id).system_groups.size == 2
          assert System.find(@system2.id).system_groups.size == 2
          assert SystemGroup.find(@group1.id).systems.size == 2
          assert SystemGroup.find(@group2.id).systems.size == 2
          put :bulk_remove_system_group, {:ids => [@system1.id, @system2.id], :group_ids => [@group1.id, @group2.id]}
          assert System.find(@system1.id).system_groups.size == 0
          assert System.find(@system2.id).system_groups.size == 0
          assert SystemGroup.find(@group1.id).systems.size == 0
          assert SystemGroup.find(@group2.id).systems.size == 0
          response.should be_success
        end

        it "should generate a notice on success" do
          controller.should notify.success
          put :bulk_remove_system_group, {:ids => [@system1.id], :group_ids => [@group1.id]}
        end
      end

      describe 'package actions' do
        before (:each) do
          @system1 = System.create!(:name=>"system1", :environment => @environment, :cp_type=>"system", :facts=>{"Test"=>""})
          @system2 = System.create!(:name=>"system2", :environment => @environment, :cp_type=>"system", :facts=>{"Test"=>""})
          System.stub(:find).and_return([@system1, @system2])
        end

        describe 'add packages' do
          pending 'should support receiving list of package names' do
            @system1.should_receive(:install_packages).with(["pkg1", "pkg2", "pkg3"])
            @system2.should_receive(:install_packages).with(["pkg1", "pkg2", "pkg3"])
            put :bulk_content_install, :ids => [@system1.id], :packages => ["pkg1", "pkg2", "pkg3"]
            response.should be_success
          end

          pending 'should generate a notice on success' do
            controller.should notify.success
            @system1.stub!(:install_packages)
            put :bulk_content_install, :ids => [@system1.id], :packages => ["pkg1"]
            response.should be_success
          end

          it 'should generate an error notice, if no package names provided' do
            controller.should notify.error
            @system1.should_not_receive(:install_packages)
            put :bulk_content_install, :ids => [@system1.id], :packages => []
            response.should be_success
          end

          it 'should return an error notice, if no packages structure provided' do
            controller.should notify.error
            @system1.should_not_receive(:install_packages)
            put :bulk_content_install, :ids => [@system1.id]
            response.should be_success
          end
        end

        describe 'add package groups' do
          pending 'should support receiving list of group names' do
            @system1.should_receive(:install_package_groups).with(["grp1", "grp2", "grp3"])
            @system2.should_receive(:install_package_groups).with(["grp1", "grp2", "grp3"])
            put :bulk_content_install, :ids => [@system1.id], :groups => ["grp1", "grp2", "grp3"]
            response.should be_success
          end

          pending 'should generate a notice on success' do
            controller.should notify.success
            @system1.stub!(:install_package_groups)
            put :bulk_content_install, :ids => [@system1.id], :groups => ["grp1"]
            response.should be_success
          end

          it 'should generate an error notice, if no group names provided' do
            controller.should notify.error
            @system1.should_not_receive(:install_package_groups)
            put :bulk_content_install, :ids => [@system1.id], :groups => []
            response.should be_success
          end

          it 'should return an error notice, if no groups structure provided' do
            controller.should notify.error
            @system1.should_not_receive(:install_package_groups)
            put :bulk_content_install, :ids => [@system1.id]
            response.should be_success
          end
        end

        describe 'update packages' do
          pending 'should support receiving list of package names' do
            @system1.should_receive(:update_packages).with(["pkg1", "pkg2", "pkg3"])
            @system2.should_receive(:update_packages).with(["pkg1", "pkg2", "pkg3"])
            put :bulk_content_update, :ids => [@system1.id], :packages => ["pkg1", "pkg2", "pkg3"]
            response.should be_success
          end

          pending 'should support receiving an empty list to support update-all' do
            @system1.should_receive(:update_packages).with([])
            @system2.should_receive(:update_packages).with([])
            put :bulk_content_update, :ids => [@system1.id], :packages => []
            response.should be_success
          end

          pending 'should generate a notice on success' do
            controller.should notify.success
            @system1.stub!(:update_packages)
            put :bulk_content_update, :ids => [@system1.id], :packages => ["pkg1"]
            response.should be_success
          end
        end

        describe 'update package groups' do
          pending 'should support receiving list of group names' do
            @system1.should_receive(:install_package_groups).with(["grp1", "grp2", "grp3"])
            @system2.should_receive(:install_package_groups).with(["grp1", "grp2", "grp3"])
            put :bulk_content_update, :ids => [@system1.id], :groups => ["grp1", "grp2", "grp3"]
            response.should be_success
          end

          pending 'should generate a notice on success' do
            controller.should notify.success
            @system1.stub!(:install_package_groups)
            put :bulk_content_update, :ids => [@system1.id], :groups => ["grp1"]
            response.should be_success
          end
        end

        describe 'remove packages' do
          pending 'should support receiving list of package names' do
            @system1.should_receive(:uninstall_packages).with(["pkg1", "pkg2", "pkg3"])
            @system2.should_receive(:uninstall_packages).with(["pkg1", "pkg2", "pkg3"])
            put :bulk_content_remove, :ids => [@system1.id], :packages => ["pkg1", "pkg2", "pkg3"]
            response.should be_success
          end

          pending 'should generate a notice on success' do
            controller.should notify.success
            @system1.stub!(:uninstall_packages)
            put :bulk_content_remove, :ids => [@system1.id], :packages => ["pkg1"]
            response.should be_success
          end

          it 'should generate an error notice, if no package names provided' do
            controller.should notify.error
            @system1.should_not_receive(:uninstall_packages)
            put :bulk_content_remove, :ids => [@system1.id], :packages => []
            response.should be_success
          end

          it 'should return an error notice, if no packages structure provided' do
            controller.should notify.error
            @system1.should_not_receive(:uninstall_packages)
            put :bulk_content_remove, :ids => [@system1.id]
            response.should be_success
          end
        end

        describe 'remove package groups' do
          pending 'should support receiving list of group names' do
            @system1.should_receive(:uninstall_packages_groups).with(["grp1", "grp2", "grp3"])
            @system2.should_receive(:uninstall_packages_groups).with(["grp1", "grp2", "grp3"])
            put :bulk_content_remove, :ids => [@system1.id], :groups => ["grp1", "grp2", "grp3"]
            response.should be_success
          end

          pending 'should generate a notice on success' do
            controller.should notify.success
            @system1.stub!(:uninstall_packages_groups)
            put :bulk_content_remove, :ids => [@system1.id], :groups => ["grp1"]
            response.should be_success
          end

          it 'should generate an error notice, if no group names provided' do
            controller.should notify.error
            @system1.should_not_receive(:uninstall_packages_groups)
            put :bulk_content_remove, :ids => [@system1.id], :groups => []
            response.should be_success
          end

          it 'should return an error notice, if no groups structure provided' do
            controller.should notify.error
            @system1.should_not_receive(:uninstall_packages_groups)
            put :bulk_content_remove, :ids => [@system1.id]
            response.should be_success
          end
        end

        describe 'install errata' do
          pending 'should support receiving list of errata' do
            @system1.should_receive(:install_errata).with(["errata1", "errata2", "errata3"])
            @system2.should_receive(:install_errata).with(["errata1", "errata2", "errata3"])
            put :bulk_errata_install, :ids => [@system1.id], :errata => ["errata1", "errata2", "errata3"]
            response.should be_success
          end

          pending 'should generate a notice on success' do
            controller.should notify.success
            @system1.stub!(:install_errata)
            put :bulk_errata_install, :ids => [@system1.id], :errata => ["errata1"]
            response.should be_success
          end

          it 'should generate an error notice, if no errata provided' do
            controller.should notify.error
            @system1.should_not_receive(:install_errata)
            put :bulk_errata_install, :ids => [@system1.id], :errata => []
            response.should be_success
          end

          it 'should return an error notice, if no errata structure provided' do
            controller.should notify.error
            @system1.should_not_receive(:install_errata)
            put :bulk_errata_install, :ids => [@system1.id]
            response.should be_success
          end
        end

      end

    end

    describe "get/set system details" do
      before (:each) do
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts => { "test" => "test" }, :serviceLevel => nil)
        System.stub(:find).and_return(@system)
      end

      it "should get release version choices" do
        @system.stub(:available_releases).and_return(["5Server", "6Server"])
        get :edit, :id => @system.id
        response.should render_template(:edit)
        assigns[:locals_hash][:releases].should == ["5Server", "6Server"]
        assigns[:locals_hash][:releases_error].should == nil
      end

      it "should get empty release version choices" do
        @system.stub(:available_releases).and_return([])
        get :edit, :id => @system.id
        response.should render_template(:edit)
        assigns[:locals_hash][:releases].should == []
        assigns[:locals_hash][:releases_error].should == nil
      end

      it "should get release version error" do
        @system.stub(:available_releases).and_raise("some error")
        get :edit, :id => @system.id
        response.should render_template(:edit)
        assigns[:locals_hash][:releases].should == []
        assigns[:locals_hash][:releases_error].should == "some error"
      end
    end

    describe "custom info" do

      before (:each) do
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts => { "test" => "test" }, :serviceLevel => nil)
        System.stub(:find).and_return(@system)
      end

      it "should render correctly" do
        get :custom_info, :id => @system.id
        response.should render_template(:edit_custom_info)
      end
    end
  end

end
