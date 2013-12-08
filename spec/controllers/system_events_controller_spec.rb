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
  describe SystemEventsController do

    include LocaleHelperMethods
    include SystemHelperMethods
    include AuthorizationHelperMethods
    include OrganizationHelperMethods

    describe "main" do
      let(:uuid) { '1234' }
      before (:each) do
        setup_controller_defaults
        @organization = setup_system_creation
        @environment  = create_environment(:name => 'test', :label => 'test', :prior => @organization.library.id, :organization => @organization)

        Resources::Candlepin::Consumer.stubs(:create).returns({ :uuid => uuid, :owner => { :key => uuid } })
        Resources::Candlepin::Consumer.stubs(:update).returns(true)
        Resources::Candlepin::Consumer.stubs(:events).returns([])

        Katello.pulp_server.extensions.consumer.stubs(:create).returns({ :id => uuid })
        Katello.pulp_server.extensions.consumer.stubs(:update).returns(true)
      end

      describe "system tasks (katello)" do
        before do
          @system = create_system(:name => "bar", :environment => @environment, :cp_type => "system", :facts => { "Test" => "" })
        end
        describe "shows the Tasks list" do
          before do
            System.any_instance.stubs(:refresh_tasks)
            Katello.pulp_server.extensions.consumer.stubs(:install_content).returns(pulp_task_without_error)
            Katello.pulp_server.resources.task.stubs(:poll).returns(pulp_task_without_error)
            stub_consumer_packages_install(pulp_task_without_error)
            @task = @system.install_packages(["foo", "bar", "bazz", "geez"])

          end
          specify "index call does the right thing" do
            get :index, :system_id => @system.id
            must_respond_with(:success)
          end

          specify "status call does the right thing" do
            get :event_status, :system_id => @system.id, :task_id => @task.id
            must_respond_with(:success)
            JSON.parse(response.body)["tasks"].first["id"].must_equal @task.id
          end

          specify "status call does the right thing for multi tasks" do
            task1 = @system.install_packages(["baz"])
            get :event_status, :system_id => @system.id, :task_id => [@task.id, task1.id]
            must_respond_with(:success)
            JSON.parse(response.body)["tasks"].collect { |item| item['id'] }.sort.must_equal [@task.id, task1.id].sort
          end

        end

      end

    end
  end
end
