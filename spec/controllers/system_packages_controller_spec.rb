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

describe SystemPackagesController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods

  describe "main" do
    let(:uuid) { '1234' }

    before (:each) do
      login_user
      set_default_locale

      @organization = setup_system_creation
      @environment = KTEnvironment.new(:name=>'test', :label=> 'test', :prior => @organization.library.id, :organization => @organization)
      @environment.save!

      Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stub!(:update).and_return(true)

      Katello.pulp_server.extensions.consumer.stub!(:create).and_return({:id => uuid})
      Katello.pulp_server.extensions.consumer.stub!(:update).and_return(true)
    end

    describe "viewing packages" do
      before (:each) do
        100.times{|a| create_system(:name=>"bar#{a}", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})}
        @systems = System.select(:id).where(:environment_id => @environment.id).all.collect{|s| s.id}
      end

      describe 'and requesting individual data' do
        before (:each) do
          @system = create_system(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})

          Katello.pulp_server.extensions.consumer.stub!(:retrieve_profile).and_return({"profile" => []})

          Resources::Candlepin::Consumer.stub!(:events).and_return([])
        end

        it "should show packages" do
          get :packages, :system_id => @system.id
          response.should be_success
          response.should render_template("packages")
        end
      end
    end

    describe 'package actions' do
      before (:each) do
        @system = create_system(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
        System.stub!(:find).and_return(@system)

        # mock task to be return when user invokes the 'action' on the model (e.g. install_packages)
        @task_status = mock_model(TaskStatus, :id => "99")
      end

      describe 'add packages' do
        it 'should support receiving a comma-separated list of package names' do
          @system.should_receive(:install_packages).with(match_array(["pkg1", "pkg2", "pkg3"])).and_return(@task_status)
          put :add, :system_id => @system.id, :packages => "pkg1, pkg2, pkg3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @system.stub!(:install_packages).and_return(@task_status)
          put :add, :system_id => @system.id, :packages => "pkg1"
          response.should be_success
        end

        it 'should render a task uuid on success' do
          @system.stub!(:install_packages).and_return(@task_status)
          put :add, :system_id => @system.id, :packages => "pkg1"
          response.should be_success
          response.should contain(@task_status.id)
        end

        it 'should generate an error notice, if no package names provided' do
          controller.should notify.error
          @system.should_not_receive(:install_packages)
          put :add, :system_id => @system.id, :packages => ""
          response.should be_success
          response.should_not contain(@task_status.id)
        end

        it 'should return an error notice, if no packages structure provided' do
          controller.should notify.error
          @system.should_not_receive(:install_packages)
          put :add, :system_id => @system.id
          response.should be_success
          response.should_not contain(@task_status.id)
        end
      end

      describe 'add package groups' do
        it 'should support receiving a comma-separated list of package groups' do
          @system.should_receive(:install_package_groups).with(match_array(["group 1", "group 2", "group3"])).and_return(@task_status)
          put :add, :system_id => @system.id, :groups => "group 1, group 2, group3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @system.stub!(:install_package_groups).and_return(@task_status)
          put :add, :system_id => @system.id, :groups => "group 1"
          response.should be_success
        end

        it 'should render a task uuid on success' do
          @system.stub!(:install_package_groups).and_return(@task_status)
          put :add, :system_id => @system.id, :groups => "group 1"
          response.should be_success
          response.should contain(@task_status.id)
        end

        it 'should generate an error notice, if no groups names provided' do
          controller.should notify.error
          @system.should_not_receive(:install_package_groups)
          put :add, :system_id => @system.id, :groups => ""
          response.should be_success
          response.should_not contain(@task_status.id)
        end

        it 'should return an error notice, if no group structure provided' do
          controller.should notify.error
          @system.should_not_receive(:install_package_groups)
          put :add, :system_id => @system.id
          response.should be_success
          response.should_not contain(@task_status.id)
        end
      end

      describe 'remove packages' do
        it 'should support receiving a comma-separated list of package names' do
          @system.should_receive(:uninstall_packages).with(match_array(["pkg1", "pkg2", "pkg3"])).and_return(@task_status)
          put :remove, :system_id => @system.id, :packages => "pkg1, pkg2, pkg3"
          response.should be_success
        end

        it 'should support receiving a hash of package names' do
          @system.should_receive(:uninstall_packages).with(match_array(["pkg1", "pkg2", "pkg3"])).and_return(@task_status)
          put :remove, :system_id => @system.id, :package => {"pkg1" => 1, "pkg2" => 1, "pkg3" => 1}
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @system.stub!(:uninstall_packages).and_return(@task_status)
          put :remove, :system_id => @system.id, :packages => "pkg1"
          response.should be_success
        end

        it 'should render a task uuid on success' do
          @system.stub!(:uninstall_packages).and_return(@task_status)
          put :remove, :system_id => @system.id, :packages => "pkg1"
          response.should be_success
          response.should contain(@task_status.id)
        end

        it 'should generate an error notice, if no packages provided' do
          controller.should notify.error
          @system.should_not_receive(:uninstall_packages)
          put :remove, :system_id => @system.id, :packages => ""
          response.should be_success
          response.should_not contain(@task_status.id)
        end

        it 'should return an error notice, if no packages structure provided' do
          controller.should notify.error
          @system.should_not_receive(:uninstall_packages)
          put :remove, :system_id => @system.id
          response.should be_success
          response.should_not contain(@task_status.id)
        end
      end

      describe 'remove package groups' do
        it 'should support receiving a comma-separated list of package groups' do
          @system.should_receive(:uninstall_package_groups).with(match_array(["group 1", "group 2", "group3"])).and_return(@task_status)
          put :remove, :system_id => @system.id, :groups => "group 1, group 2, group3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @system.stub!(:uninstall_package_groups).and_return(@task_status)
          put :remove, :system_id => @system.id, :groups => "group 1"
          response.should be_success
        end

        it 'should render a task uuid on success' do
          @system.stub!(:uninstall_package_groups).and_return(@task_status)
          put :remove, :system_id => @system.id, :groups => "group 1"
          response.should be_success
          response.should contain(@task_status.id)
        end

        it 'should generate an error notice, if no group names provided' do
          controller.should notify.error
          @system.should_not_receive(:uninstall_package_groups)
          put :remove, :system_id => @system.id, :groups => ""
          response.should be_success
          response.should_not contain(@task_status.id)
        end

        it 'should return an error notice, if no groups structure provided' do
          controller.should notify.error
          @system.should_not_receive(:uninstall_package_groups)
          put :remove, :system_id => @system.id
          response.should be_success
          response.should_not contain(@task_status.id)
        end
      end

      describe 'update packages' do
        describe 'list of packages provided' do
          it 'should support receiving a hash of package names' do
            @system.should_receive(:update_packages).with(match_array(["pkg1", "pkg2", "pkg3"])).and_return(@task_status)
            put :update, :system_id => @system.id, :package => {"pkg1" => 1, "pkg2" => 1, "pkg3" => 1}
            response.should be_success
          end

          it 'should generate a notice on success' do
            controller.should notify.success
            @system.stub!(:update_packages).and_return(@task_status)
            put :update, :system_id => @system.id, :packages => {"pkg1" => 1}
            response.should be_success
          end

          it 'should render a task uuid on success' do
            @system.stub!(:update_packages).and_return(@task_status)
            put :update, :system_id => @system.id, :packages => {"pkg1" => 1}
            response.should be_success
            response.should contain(@task_status.id)
          end
        end

        describe 'no packages provided (update all)' do
          it 'treat request without packages as an update all' do
            @system.should_receive(:update_packages).with(nil).and_return(@task_status)
            put :update, :system_id => @system.id
            response.should be_success
          end

          it 'should generate a notice on success' do
            controller.should notify.success
            @system.stub!(:update_packages).and_return(@task_status)
            put :update, :system_id => @system.id
            response.should be_success
          end

          it 'should render a task uuid on success' do
            @system.stub!(:update_packages).and_return(@task_status)
            put :update, :system_id => @system.id
            response.should be_success
            response.should contain(@task_status.id)
          end
        end
      end
    end
  end
end
