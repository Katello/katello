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
  describe SystemPackagesController do

    include LocaleHelperMethods
    include SystemHelperMethods
    include AuthorizationHelperMethods
    include OrganizationHelperMethods

    describe "main (katello)" do
      let(:uuid) { '1234' }

      before (:each) do
        setup_controller_defaults

        @organization = setup_system_creation
        @environment  = KTEnvironment.new(:name => 'test', :label => 'test', :prior => @organization.library.id, :organization => @organization)
        @environment.save!

        Resources::Candlepin::Consumer.stubs(:create).returns({ :uuid => uuid, :owner => { :key => uuid } })
        Resources::Candlepin::Consumer.stubs(:update).returns(true)

        Katello.pulp_server.extensions.consumer.stubs(:create).returns({ :id => uuid })
        Katello.pulp_server.extensions.consumer.stubs(:update).returns(true)
      end

      describe "viewing packages" do
        before (:each) do
          100.times { |a| create_system(:name => "bar#{a}", :environment => @environment, :cp_type => "system", :facts => { "Test" => "" }) }
          @systems = System.select(:id).where(:environment_id => @environment.id).all.collect { |s| s.id }
        end

        describe 'and requesting individual data' do
          before (:each) do
            @system = create_system(:name => "verbose", :environment => @environment, :cp_type => "system", :facts => { "Test1" => 1, "verbose_facts" => "Test facts" })

            System.any_instance.stubs(:fetch_package_profile).returns({ "profile" => [] })

            Resources::Candlepin::Consumer.stubs(:events).returns([])
          end

          it "should show packages" do
            get :packages, :system_id => @system.id
            must_respond_with(:success)
            must_render_template("packages")
          end
        end
      end

      describe 'package actions' do
        before (:each) do
          @system = create_system(:name => "bar", :environment => @environment, :cp_type => "system", :facts => { "Test" => "" })
          System.stubs(:find).returns(@system)

          # mock task to be return when user invokes the 'action' on the model (e.g. install_packages)
          @task_status = OpenStruct.new(:id => "99")
        end

        describe 'add packages' do
          it 'should support receiving a comma-separated list of package names' do
            @system.expects(:install_packages).with(["pkg1", "pkg2", "pkg3"]).returns(@task_status)
            put :add, :system_id => @system.id, :packages => "pkg1, pkg2, pkg3"
            must_respond_with(:success)
          end

          it 'should generate a notice on success' do
            must_notify_with(:success)
            @system.stubs(:install_packages).returns(@task_status)
            put :add, :system_id => @system.id, :packages => "pkg1"
            must_respond_with(:success)
          end

          it 'should render a task uuid on success' do
            @system.stubs(:install_packages).returns(@task_status)
            put :add, :system_id => @system.id, :packages => "pkg1"
            must_respond_with(:success)
            response.body.must_include(@task_status.id)
          end

          it 'should generate an error notice, if no package names provided' do
            must_notify_with(:error)
            @system.expects(:install_packages).never
            put :add, :system_id => @system.id, :packages => ""
            must_respond_with(:success)
            response.wont_include(@task_status.id)
          end

          it 'should return an error notice, if no packages structure provided' do
            must_notify_with(:error)
            @system.expects(:install_packages).never
            put :add, :system_id => @system.id
            must_respond_with(:success)
            response.wont_include(@task_status.id)
          end
        end

        describe 'add package groups' do
          it 'should support receiving a comma-separated list of package groups' do
            @system.expects(:install_package_groups).with(["group 1", "group 2", "group3"]).returns(@task_status)
            put :add, :system_id => @system.id, :groups => "group 1, group 2, group3"
            must_respond_with(:success)
          end

          it 'should generate a notice on success' do
            must_notify_with(:success)
            @system.stubs(:install_package_groups).returns(@task_status)
            put :add, :system_id => @system.id, :groups => "group 1"
            must_respond_with(:success)
          end

          it 'should render a task uuid on success' do
            @system.stubs(:install_package_groups).returns(@task_status)
            put :add, :system_id => @system.id, :groups => "group 1"
            must_respond_with(:success)
            response.body.must_include(@task_status.id)
          end

          it 'should generate an error notice, if no groups names provided' do
            must_notify_with(:error)
            @system.expects(:install_package_groups).never
            put :add, :system_id => @system.id, :groups => ""
            must_respond_with(:success)
            response.wont_include(@task_status.id)
          end

          it 'should return an error notice, if no group structure provided' do
            must_notify_with(:error)
            @system.expects(:install_package_groups).never
            put :add, :system_id => @system.id
            must_respond_with(:success)
            response.wont_include(@task_status.id)
          end
        end

        describe 'remove packages' do
          it 'should support receiving a comma-separated list of package names' do
            @system.expects(:uninstall_packages).with(["pkg1", "pkg2", "pkg3"]).returns(@task_status)
            put :remove, :system_id => @system.id, :packages => "pkg1, pkg2, pkg3"
            must_respond_with(:success)
          end

          it 'should support receiving a hash of package names' do
            @system.expects(:uninstall_packages).with(["pkg1", "pkg2", "pkg3"]).returns(@task_status)
            put :remove, :system_id => @system.id, :package => { "pkg1" => 1, "pkg2" => 1, "pkg3" => 1 }
            must_respond_with(:success)
          end

          it 'should generate a notice on success' do
            must_notify_with(:success)
            @system.stubs(:uninstall_packages).returns(@task_status)
            put :remove, :system_id => @system.id, :packages => "pkg1"
            must_respond_with(:success)
          end

          it 'should render a task uuid on success' do
            @system.stubs(:uninstall_packages).returns(@task_status)
            put :remove, :system_id => @system.id, :packages => "pkg1"
            must_respond_with(:success)
            response.body.must_include(@task_status.id)
          end

          it 'should generate an error notice, if no packages provided' do
            must_notify_with(:error)
            @system.expects(:uninstall_packages).never
            put :remove, :system_id => @system.id, :packages => ""
            must_respond_with(:success)
            response.wont_include(@task_status.id)
          end

          it 'should return an error notice, if no packages structure provided' do
            must_notify_with(:error)
            @system.expects(:uninstall_packages).never
            put :remove, :system_id => @system.id
            must_respond_with(:success)
            response.wont_include(@task_status.id)
          end
        end

        describe 'remove package groups' do
          it 'should support receiving a comma-separated list of package groups' do
            @system.expects(:uninstall_package_groups).with(["group 1", "group 2", "group3"]).returns(@task_status)
            put :remove, :system_id => @system.id, :groups => "group 1, group 2, group3"
            must_respond_with(:success)
          end

          it 'should generate a notice on success' do
            must_notify_with(:success)
            @system.stubs(:uninstall_package_groups).returns(@task_status)
            put :remove, :system_id => @system.id, :groups => "group 1"
            must_respond_with(:success)
          end

          it 'should render a task uuid on success' do
            @system.stubs(:uninstall_package_groups).returns(@task_status)
            put :remove, :system_id => @system.id, :groups => "group 1"
            must_respond_with(:success)
            response.body.must_include(@task_status.id)
          end

          it 'should generate an error notice, if no group names provided' do
            must_notify_with(:error)
            @system.expects(:uninstall_package_groups).never
            put :remove, :system_id => @system.id, :groups => ""
            must_respond_with(:success)
            response.wont_include(@task_status.id)
          end

          it 'should return an error notice, if no groups structure provided' do
            must_notify_with(:error)
            @system.expects(:uninstall_package_groups).never
            put :remove, :system_id => @system.id
            must_respond_with(:success)
            response.wont_include(@task_status.id)
          end
        end

        describe 'update packages' do
          describe 'list of packages provided' do
            it 'should support receiving a hash of package names' do
              @system.expects(:update_packages).with(["pkg1", "pkg2", "pkg3"]).returns(@task_status)
              put :update, :system_id => @system.id, :package => { "pkg1" => 1, "pkg2" => 1, "pkg3" => 1 }
              must_respond_with(:success)
            end

            it 'should generate a notice on success' do
              must_notify_with(:success)
              @system.stubs(:update_packages).returns(@task_status)
              put :update, :system_id => @system.id, :packages => { "pkg1" => 1 }
              must_respond_with(:success)
            end

            it 'should render a task uuid on success' do
              @system.stubs(:update_packages).returns(@task_status)
              put :update, :system_id => @system.id, :packages => { "pkg1" => 1 }
              must_respond_with(:success)
              response.body.must_include(@task_status.id)
            end
          end

          describe 'no packages provided (update all)' do
            it 'treat request without packages as an update all' do
              @system.expects(:update_packages).with(nil).returns(@task_status)
              put :update, :system_id => @system.id
              must_respond_with(:success)
            end

            it 'should generate a notice on success' do
              must_notify_with(:success)
              @system.stubs(:update_packages).returns(@task_status)
              put :update, :system_id => @system.id
              must_respond_with(:success)
            end

            it 'should render a task uuid on success' do
              @system.stubs(:update_packages).returns(@task_status)
              put :update, :system_id => @system.id
              must_respond_with(:success)
              response.body.must_include(@task_status.id)
            end
          end
        end
      end
    end
  end
end
