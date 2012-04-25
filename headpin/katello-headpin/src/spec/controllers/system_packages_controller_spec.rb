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
      @environment = KTEnvironment.new(:name => 'test', :prior => @organization.library.id, :organization => @organization)
      @environment.save!

      controller.stub!(:notice)

      Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Candlepin::Consumer.stub!(:update).and_return(true)

      Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Pulp::Consumer.stub!(:update).and_return(true)
    end

    describe "viewing packages" do
      before (:each) do
        100.times{|a| System.create!(:name=>"bar#{a}", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})}
        @systems = System.select(:id).where(:environment_id => @environment.id).all.collect{|s| s.id}
      end

      describe 'and requesting individual data' do
        before (:each) do
          @system = System.create!(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})

          Pulp::Consumer.stub!(:installed_packages).and_return([])
          Candlepin::Consumer.stub!(:events).and_return([])
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
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
        System.stub!(:find).and_return(@system)

        # mock task to be return when user invokes the 'action' on the model (e.g. install_packages)
        task_status = mock_model(TaskStatus, :uuid => "task_uuid_123")
        @system_task = mock_model(SystemTask, :task_status => task_status)
      end

      describe 'add packages' do
        it 'should support receiving a comma-separated list of package names' do
          @system.should_receive(:install_packages).with(["pkg1", "pkg2", "pkg3"]).and_return(@system_task)
          put :add, :system_id => @system.id, :packages => "pkg1, pkg2, pkg3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should_receive(:notice)
          @system.stub!(:install_packages).and_return(@system_task)
          put :add, :system_id => @system.id, :packages => "pkg1"
          response.should be_success
        end

        it 'should render a task uuid on success' do
          @system.stub!(:install_packages).and_return(@system_task)
          put :add, :system_id => @system.id, :packages => "pkg1"
          response.should be_success
          response.should contain(@system_task.task_status.uuid)
        end

        it 'should generate an error notice, if no package names provided' do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          @system.should_not_receive(:install_packages)
          put :add, :system_id => @system.id, :packages => ""
          response.should be_success
          response.should_not contain(@system_task.task_status.uuid)
        end

        it 'should return an error notice, if no packages structure provided' do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          @system.should_not_receive(:install_packages)
          put :add, :system_id => @system.id
          response.should be_success
          response.should_not contain(@system_task.task_status.uuid)
        end
      end

      describe 'add package groups' do
        it 'should support receiving a comma-separated list of package groups' do
          @system.should_receive(:install_package_groups).with(["group 1", "group 2", "group3"]).and_return(@system_task)
          put :add, :system_id => @system.id, :groups => "group 1, group 2, group3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should_receive(:notice)
          @system.stub!(:install_package_groups).and_return(@system_task)
          put :add, :system_id => @system.id, :groups => "group 1"
          response.should be_success
        end

        it 'should render a task uuid on success' do
          @system.stub!(:install_package_groups).and_return(@system_task)
          put :add, :system_id => @system.id, :groups => "group 1"
          response.should be_success
          response.should contain(@system_task.task_status.uuid)
        end

        it 'should generate an error notice, if no groups names provided' do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          @system.should_not_receive(:install_package_groups)
          put :add, :system_id => @system.id, :groups => ""
          response.should be_success
          response.should_not contain(@system_task.task_status.uuid)
        end

        it 'should return an error notice, if no group structure provided' do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          @system.should_not_receive(:install_package_groups)
          put :add, :system_id => @system.id
          response.should be_success
          response.should_not contain(@system_task.task_status.uuid)
        end
      end

      describe 'remove packages' do
        it 'should support receiving a comma-separated list of package names' do
          @system.should_receive(:uninstall_packages).with(["pkg1", "pkg2", "pkg3"]).and_return(@system_task)
          put :remove, :system_id => @system.id, :packages => "pkg1, pkg2, pkg3"
          response.should be_success
        end

        it 'should support receiving a hash of package names' do
          @system.should_receive(:uninstall_packages).with(["pkg1", "pkg2", "pkg3"]).and_return(@system_task)
          put :remove, :system_id => @system.id, :package => {"pkg1" => 1, "pkg2" => 1, "pkg3" => 1}
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should_receive(:notice)
          @system.stub!(:uninstall_packages).and_return(@system_task)
          put :remove, :system_id => @system.id, :packages => "pkg1"
          response.should be_success
        end

        it 'should render a task uuid on success' do
          @system.stub!(:uninstall_packages).and_return(@system_task)
          put :remove, :system_id => @system.id, :packages => "pkg1"
          response.should be_success
          response.should contain(@system_task.task_status.uuid)
        end

        it 'should generate an error notice, if no packages provided' do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          @system.should_not_receive(:uninstall_packages)
          put :remove, :system_id => @system.id, :packages => ""
          response.should be_success
          response.should_not contain(@system_task.task_status.uuid)
        end

        it 'should return an error notice, if no packages structure provided' do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          @system.should_not_receive(:uninstall_packages)
          put :remove, :system_id => @system.id
          response.should be_success
          response.should_not contain(@system_task.task_status.uuid)
        end
      end

      describe 'remove package groups' do
        it 'should support receiving a comma-separated list of package groups' do
          @system.should_receive(:uninstall_package_groups).with(["group 1", "group 2", "group3"]).and_return(@system_task)
          put :remove, :system_id => @system.id, :groups => "group 1, group 2, group3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should_receive(:notice)
          @system.stub!(:uninstall_package_groups).and_return(@system_task)
          put :remove, :system_id => @system.id, :groups => "group 1"
          response.should be_success
        end

        it 'should render a task uuid on success' do
          @system.stub!(:uninstall_package_groups).and_return(@system_task)
          put :remove, :system_id => @system.id, :groups => "group 1"
          response.should be_success
          response.should contain(@system_task.task_status.uuid)
        end

        it 'should generate an error notice, if no group names provided' do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          @system.should_not_receive(:uninstall_package_groups)
          put :remove, :system_id => @system.id, :groups => ""
          response.should be_success
          response.should_not contain(@system_task.task_status.uuid)
        end

        it 'should return an error notice, if no groups structure provided' do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          @system.should_not_receive(:uninstall_package_groups)
          put :remove, :system_id => @system.id
          response.should be_success
          response.should_not contain(@system_task.task_status.uuid)
        end
      end

      describe 'update packages' do
        describe 'list of packages provided' do
          it 'should support receiving a hash of package names' do
            @system.should_receive(:update_packages).with(["pkg1", "pkg2", "pkg3"]).and_return(@system_task)
            put :update, :system_id => @system.id, :package => {"pkg1" => 1, "pkg2" => 1, "pkg3" => 1}
            response.should be_success
          end

          it 'should generate a notice on success' do
            controller.should_receive(:notice)
            @system.stub!(:update_packages).and_return(@system_task)
            put :update, :system_id => @system.id, :packages => {"pkg1" => 1}
            response.should be_success
          end

          it 'should render a task uuid on success' do
            @system.stub!(:update_packages).and_return(@system_task)
            put :update, :system_id => @system.id, :packages => {"pkg1" => 1}
            response.should be_success
            response.should contain(@system_task.task_status.uuid)
          end
        end

        describe 'no packages provided (update all)' do
          it 'treat request without packages as an update all' do
            @system.should_receive(:update_packages).with(nil).and_return(@system_task)
            put :update, :system_id => @system.id
            response.should be_success
          end

          it 'should generate a notice on success' do
            controller.should_receive(:notice)
            @system.stub!(:update_packages).and_return(@system_task)
            put :update, :system_id => @system.id
            response.should be_success
          end

          it 'should render a task uuid on success' do
            @system.stub!(:update_packages).and_return(@system_task)
            put :update, :system_id => @system.id
            response.should be_success
            response.should contain(@system_task.task_status.uuid)
          end
        end
      end
    end
  end
end
