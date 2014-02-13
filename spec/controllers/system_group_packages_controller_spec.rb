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

require 'katello_test_helper'

module Katello
describe SystemGroupPackagesController do

  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods
  include OrganizationHelperMethods

  describe "main (katello)" do
    let(:uuid) { '1234' }

    before (:each) do
      setup_controller_defaults
      disable_org_orchestration
      disable_consumer_group_orchestration

      @organization = get_organization
      @controller.stubs(:current_organization).returns(@organization)

      @environment = create_environment(:name=>"DEV", :label=> "DEV",
                                        :prior=>@organization.library, :organization=>@organization)

      Resources::Candlepin::Consumer.stubs(:create).returns({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stubs(:update).returns(true)

      Katello.pulp_server.extensions.consumer.stubs(:create).returns({:id => uuid})
      Katello.pulp_server.extensions.consumer.stubs(:update).returns(true)
      System.any_instance.stubs(:update_system_groups)

      @group = SystemGroup.new(:name=>"test_group", :organization=>@organization)
      @system = create_system(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})
      @group.save!
      @group.systems << @system
      @controller.expects(:render).twice
    end

    describe 'package actions' do
      before (:each) do
        SystemGroup.stubs(:find).returns(@group)

        # mock job to be return when user invokes the 'action' on the model (e.g. install_packages)
        @job = OpenStruct.new(:pulp_id => "job_pulp_id_123")
      end

      describe 'add packages' do
        it 'should support receiving a comma-separated list of package names' do
          @group.expects(:install_packages).with(["pkg1", "pkg2", "pkg3"]).returns(@job)
          put :add, :system_group_id => @group.id, :packages => "pkg1, pkg2, pkg3"
          must_respond_with(:success)
        end

        it 'should generate a notice on success' do
          must_notify_with(:success)
          @group.stubs(:install_packages).returns(@job)
          put :add, :system_group_id => @group.id, :packages => "pkg1"
          must_respond_with(:success)
        end

        it 'should generate an error notice, if no package names provided' do
          must_notify_with(:error)
          @group.expects(:install_packages).never
          put :add, :system_group_id => @group.id, :packages => ""
          must_respond_with(:success)
        end

        it 'should return an error notice, if no packages structure provided' do
          must_notify_with(:error)
          @group.expects(:install_packages).never
          put :add, :system_group_id => @group.id
          must_respond_with(:success)
        end
      end

      describe 'add package groups' do
        it 'should support receiving a comma-separated list of package group names' do
          @group.expects(:install_package_groups).with(["grp1", "grp2", "grp3"]).returns(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1, grp2, grp3"
          must_respond_with(:success)
        end

        it 'should generate a notice on success' do
          must_notify_with(:success)
          @group.stubs(:install_package_groups).returns(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1"
          must_respond_with(:success)
        end

        it 'should generate an error notice, if no package group names provided' do
          must_notify_with(:error)
          @group.expects(:install_package_groups).never
          put :add, :system_group_id => @group.id, :groups => ""
          must_respond_with(:success)
        end

        it 'should return an error notice, if no package group structure provided' do
          must_notify_with(:error)
          @group.expects(:install_package_groups).never
          put :add, :system_group_id => @group.id
          must_respond_with(:success)
        end
      end

      describe 'remove packages' do
        it 'should support receiving a comma-separated list of package names' do
          @group.expects(:uninstall_packages).with(["pkg1", "pkg2", "pkg3"]).returns(@job)
          put :remove, :system_group_id => @group.id, :packages => "pkg1, pkg2, pkg3"
          must_respond_with(:success)
        end

        it 'should generate a notice on success' do
          must_notify_with(:success)
          @group.stubs(:uninstall_packages).returns(@job)
          put :remove, :system_group_id => @group.id, :packages => "pkg1"
          must_respond_with(:success)
        end

        it 'should generate an error notice, if no package names provided' do
          must_notify_with(:error)
          @group.expects(:uninstall_packages).never
          put :remove, :system_group_id => @group.id, :packages => ""
          must_respond_with(:success)
        end

        it 'should return an error notice, if no packages structure provided' do
          must_notify_with(:error)
          @group.expects(:uninstall_packages).never
          put :remove, :system_group_id => @group.id
          must_respond_with(:success)
        end
      end

      describe 'remove package groups' do
        it 'should support receiving a comma-separated list of package group names' do
          @group.expects(:uninstall_package_groups).with(["grp1", "grp2", "grp3"]).returns(@job)
          put :remove, :system_group_id => @group.id, :groups => "grp1, grp2, grp3"
          must_respond_with(:success)
        end

        it 'should generate a notice on success' do
          must_notify_with(:success)
          @group.stubs(:uninstall_package_groups).returns(@job)
          put :remove, :system_group_id => @group.id, :groups => "grp1"
          must_respond_with(:success)
        end

        it 'should generate an error notice, if no package group names provided' do
          must_notify_with(:error)
          @group.expects(:uninstall_package_groups).never
          put :remove, :system_group_id => @group.id, :groups => ""
          must_respond_with(:success)
        end

        it 'should return an error notice, if no package group structure provided' do
          must_notify_with(:error)
          @group.expects(:uninstall_package_groups).never
          put :remove, :system_group_id => @group.id
          must_respond_with(:success)
        end
      end

      describe 'add package groups' do
        it 'should support receiving a comma-separated list of package group names' do
          @group.expects(:install_package_groups).with(["grp1", "grp2", "grp3"]).returns(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1, grp2, grp3"
          must_respond_with(:success)
        end

        it 'should generate a notice on success' do
          must_notify_with(:success)
          @group.stubs(:install_package_groups).returns(@job)
          put :add, :system_group_id => @group.id, :groups => "grp1"
          must_respond_with(:success)
        end

        it 'should generate an error notice, if no package group names provided' do
          must_notify_with(:error)
          @group.expects(:install_package_groups).never
          put :add, :system_group_id => @group.id, :groups => ""
          must_respond_with(:success)
        end

        it 'should return an error notice, if no package group structure provided' do
          must_notify_with(:error)
          @group.expects(:install_package_groups).never
          put :add, :system_group_id => @group.id
          must_respond_with(:success)
        end
      end

      describe 'update packages' do
        it 'should support receiving a comma-separated list of package names' do
          @group.expects(:update_packages).with(["pkg1", "pkg2", "pkg3"]).returns(@job)
          put :update, :system_group_id => @group.id, :packages => "pkg1, pkg2, pkg3"
          must_respond_with(:success)
        end

        it 'should generate a notice on success' do
          must_notify_with(:success)
          @group.stubs(:update_packages).returns(@job)
          put :update, :system_group_id => @group.id, :packages => "pkg1"
          must_respond_with(:success)
        end
      end

      describe 'update all packages' do
        it 'should support an empty package list' do
          @group.expects(:update_packages).with([]).returns(@job)
          put :update, :system_group_id => @group.id, :packages => ""
          must_respond_with(:success)
        end

        it 'should generate a notice on success' do
          must_notify_with(:success)
          @group.stubs(:update_packages).returns(@job)
          put :update, :system_group_id => @group.id, :packages => ""
          must_respond_with(:success)
        end
      end

      describe 'update package groups' do
        it 'should support receiving a comma-separated list of package group names' do
          @group.expects(:update_package_groups).with(["grp1", "grp2", "grp3"]).returns(@job)
          put :update, :system_group_id => @group.id, :groups => "grp1, grp2, grp3"
          must_respond_with(:success)
        end

        it 'should generate a notice on success' do
          must_notify_with(:success)
          @group.stubs(:update_package_groups).returns(@job)
          put :update, :system_group_id => @group.id, :groups => "grp1"
          must_respond_with(:success)
        end

        it 'should generate an error notice, if no package group names provided' do
          must_notify_with(:error)
          @group.expects(:update_package_groups).never
          put :update, :system_group_id => @group.id, :groups => ""
          must_respond_with(:success)
        end

        it 'should return an error notice, if no package group structure provided' do
          must_notify_with(:error)
          @group.expects(:update_package_groups).never
          put :update, :system_group_id => @group.id
          must_respond_with(:success)
        end
      end

    end
  end
end
end
