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
describe SystemGroupErrataController do

  include LocaleHelperMethods
  include SystemHelperMethods
  include OrchestrationHelper
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  describe "main (katello)" do
    let(:uuid) { '1234' }

    before (:each) do
      setup_controller_defaults
      disable_org_orchestration
      disable_consumer_group_orchestration

      @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @environment = create_environment(:name=>"DEV", :label=> "DEV", :prior=>@org.library, :organization=>@org)

      Resources::Candlepin::Consumer.stubs(:create).returns({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stubs(:update).returns(true)

      Katello.pulp_server.extensions.consumer.stubs(:create).returns({:id => uuid})
      Katello.pulp_server.extensions.consumer.stubs(:update).returns(true)

      @group = SystemGroup.new(:name=>"test_group", :organization=>@org)
      @system = create_system(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})
      @group.save!
      @group.systems << @system
    end

    describe "viewing system groups" do
      describe 'and requesting errata' do
        before (:each) do
          types = [Glue::Pulp::Errata::SECURITY, Glue::Pulp::Errata::ENHANCEMENT, Glue::Pulp::Errata::BUGZILLA]

          to_ret = []
          40.times{ |num|
            errata           = OpenStruct.new
            errata.id        = "8a604f44-6877-4c81-b6f9-#{num}"
            errata.errata_id = "RHSA-2011-01-#{num}"
            errata.type      = types[rand(3)]
            errata.applicable_consumers = []
            errata.release   = "Red Hat Enterprise Linux 6.0"
            to_ret << errata
          }
          Errata.stubs(:applicable_for_consumers).returns(to_ret)
        end

        describe 'on initial load' do
          it "should be successful" do
            get :index, :system_group_id => @group.id
            must_respond_with(:success)
          end

          it "should render errata template" do
            get :index, :system_group_id => @group.id
            must_render_template("index")
          end
        end

        describe 'with an offset' do
          it "should be successful" do
            get :items, :system_group_id => @group.id, :offset => 25
            must_respond_with(:success)
          end

          it "should render errata items" do
            get :items, :system_group_id => @group.id, :offset => 25
            must_render_template("items")
          end
        end

        describe 'with a filter type' do
          it "should be successful" do
            get :items, :system_group_id => @group.id, :offset => 5, :filter_type => 'BugFix'
            must_respond_with(:success)
          end

          it "should render errata items" do
            get :items, :system_group_id => @group.id, :offset => 5, :filter_type => 'BugFix'
            must_render_template("items")
          end
        end

      end
    end
  end
end
end
