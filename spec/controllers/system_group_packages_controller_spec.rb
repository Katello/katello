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

describe SystemGroupPackagesController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods

  describe "main" do
    let(:uuid) { '1234' }

    before (:each) do
      login_user
      set_default_locale
      disable_org_orchestration
      disable_consumer_group_orchestration

      @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @environment = create_environment(:name=>"DEV", :label=> "DEV", :prior=>@org.library, :organization=>@org)

      Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stub!(:update).and_return(true)

      Runcible::Extensions::Consumer.stub!(:create).and_return({:id => uuid})
      Runcible::Extensions::Consumer.stub!(:update).and_return(true)

      @group = SystemGroup.new(:name=>"test_group", :organization=>@org)
      @system = create_system(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})
      @group.save!
      @group.systems << @system
    end

    describe 'package actions' do
      before (:each) do
        SystemGroup.stub!(:find).and_return(@group)

        # mock job to be return when user invokes the 'action' on the model (e.g. install_packages)
        @job = mock_model(Job, :pulp_id => "job_pulp_id_123")
      end

      describe 'add packages' do
        it 'should support receiving a comma-separated list of package names' do
          @group.should_receive(:install_packages).with(["pkg1", "pkg2", "pkg3"]).and_return(@job)
          put :add, :system_group_id => @group.id, :packages => "pkg1, pkg2, pkg3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @group.stub!(:install_packages).and_return(@job)
          put :add, :system_group_id => @group.id, :packages => "pkg1"
          response.should be_success
        end

        it 'should render the items partial on success' do
          @group.stub!(:install_packages).and_return(@job)
          put :add, :system_group_id => @group.id, :packages => "pkg1"
          response.should be_success
          response.should render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should generate an error notice, if no package names provided' do
          controller.should notify.error
          @group.should_not_receive(:install_packages)
          put :add, :system_group_id => @group.id, :packages => ""
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should return an error notice, if no packages structure provided' do
          controller.should notify.error
          @group.should_not_receive(:install_packages)
          put :add, :system_group_id => @group.id
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end
      end

      describe 'add package groups' do
        it 'should support receiving a comma-separated list of package group names' do
          @group.should_receive(:install_package_groups).with(["grp1", "grp2", "grp3"]).and_return(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1, grp2, grp3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @group.stub!(:install_package_groups).and_return(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1"
          response.should be_success
        end

        it 'should render the items partial on success' do
          @group.stub!(:install_package_groups).and_return(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1"
          response.should be_success
          response.should render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should generate an error notice, if no package group names provided' do
          controller.should notify.error
          @group.should_not_receive(:install_package_groups)
          put :add, :system_group_id => @group.id, :groups => ""
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should return an error notice, if no package group structure provided' do
          controller.should notify.error
          @group.should_not_receive(:install_package_groups)
          put :add, :system_group_id => @group.id
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end
      end

      describe 'remove packages' do
        it 'should support receiving a comma-separated list of package names' do
          @group.should_receive(:uninstall_packages).with(["pkg1", "pkg2", "pkg3"]).and_return(@job)
          put :remove, :system_group_id => @group.id, :packages => "pkg1, pkg2, pkg3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @group.stub!(:uninstall_packages).and_return(@job)
          put :remove, :system_group_id => @group.id, :packages => "pkg1"
          response.should be_success
        end

        it 'should render the items partial on success' do
          @group.stub!(:uninstall_packages).and_return(@job)
          put :remove, :system_group_id => @group.id, :packages => "pkg1"
          response.should be_success
          response.should render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should generate an error notice, if no package names provided' do
          controller.should notify.error
          @group.should_not_receive(:uninstall_packages)
          put :remove, :system_group_id => @group.id, :packages => ""
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should return an error notice, if no packages structure provided' do
          controller.should notify.error
          @group.should_not_receive(:uninstall_packages)
          put :remove, :system_group_id => @group.id
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end
      end

      describe 'remove package groups' do
        it 'should support receiving a comma-separated list of package group names' do
          @group.should_receive(:uninstall_package_groups).with(["grp1", "grp2", "grp3"]).and_return(@job)
          put :remove, :system_group_id => @group.id, :groups => "grp1, grp2, grp3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @group.stub!(:uninstall_package_groups).and_return(@job)
          put :remove, :system_group_id => @group.id, :groups => "grp1"
          response.should be_success
        end

        it 'should render the items partial on success' do
          @group.stub!(:uninstall_package_groups).and_return(@job)
          put :remove, :system_group_id => @group.id, :groups => "grp1"
          response.should be_success
          response.should render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should generate an error notice, if no package group names provided' do
          controller.should notify.error
          @group.should_not_receive(:uninstall_package_groups)
          put :remove, :system_group_id => @group.id, :groups => ""
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should return an error notice, if no package group structure provided' do
          controller.should notify.error
          @group.should_not_receive(:uninstall_package_groups)
          put :remove, :system_group_id => @group.id
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end
      end

      describe 'add package groups' do
        it 'should support receiving a comma-separated list of package group names' do
          @group.should_receive(:install_package_groups).with(["grp1", "grp2", "grp3"]).and_return(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1, grp2, grp3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @group.stub!(:install_package_groups).and_return(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1"
          response.should be_success
        end

        it 'should render the items partial on success' do
          @group.stub!(:install_package_groups).and_return(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1"
          response.should be_success
          response.should render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should generate an error notice, if no package group names provided' do
          controller.should notify.error
          @group.should_not_receive(:install_package_groups)
          put :add, :system_group_id => @group.id, :groups => ""
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should return an error notice, if no package group structure provided' do
          controller.should notify.error
          @group.should_not_receive(:install_package_groups)
          put :add, :system_group_id => @group.id
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end
      end

      describe 'update packages' do
        it 'should support receiving a comma-separated list of package names' do
          @group.should_receive(:update_packages).with(["pkg1", "pkg2", "pkg3"]).and_return(@job)
          put :update, :system_group_id => @group.id, :packages => "pkg1, pkg2, pkg3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @group.stub!(:update_packages).and_return(@job)
          put :update, :system_group_id => @group.id, :packages => "pkg1"
          response.should be_success
        end

        it 'should render the items partial on success' do
          @group.stub!(:update_packages).and_return(@job)
          put :update, :system_group_id => @group.id, :packages => "pkg1"
          response.should be_success
          response.should render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should generate an error notice, if no package names provided' do
          controller.should notify.error
          @group.should_not_receive(:update_packages)
          put :update, :system_group_id => @group.id, :packages => ""
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should return an error notice, if no packages structure provided' do
          controller.should notify.error
          @group.should_not_receive(:update_packages)
          put :update, :system_group_id => @group.id
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end
      end

      describe 'update package groups' do
        it 'should support receiving a comma-separated list of package group names' do
          @group.should_receive(:update_package_groups).with(["grp1", "grp2", "grp3"]).and_return(@job)
          put :update, :system_group_id => @group.id, :groups => "grp1, grp2, grp3"
          response.should be_success
        end

        it 'should generate a notice on success' do
          controller.should notify.success
          @group.stub!(:update_package_groups).and_return(@job)
          put :update, :system_group_id => @group.id, :groups => "grp1"
          response.should be_success
        end

        it 'should render the items partial on success' do
          @group.stub!(:update_package_groups).and_return(@job)
          put :update, :system_group_id => @group.id, :groups => "grp1"
          response.should be_success
          response.should render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should generate an error notice, if no package group names provided' do
          controller.should notify.error
          @group.should_not_receive(:update_package_groups)
          put :update, :system_group_id => @group.id, :groups => ""
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end

        it 'should return an error notice, if no package group structure provided' do
          controller.should notify.error
          @group.should_not_receive(:update_package_groups)
          put :update, :system_group_id => @group.id
          response.should be_success
          response.should_not render_template(:partial => 'system_groups/packages/_items')
        end
      end

    end
  end
end
