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
include OrchestrationHelper

describe Api::V1::SubscriptionsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods

  let(:facts) { { "distribution.name" => "Fedora" } }
  let(:uuid) { '1234' }

  let(:user_with_read_permissions) { user_with_permissions { |u| u.can(:read_systems, :organizations, nil, @organization) } }
  let(:user_without_read_permissions) { user_without_permissions }
  let(:user_with_update_permissions) { user_with_permissions { |u| u.can([:read_systems, :update_systems], :organizations, nil, @organization) } }
  let(:user_without_update_permissions) { user_without_permissions }

  before (:each) do
    login_user
    set_default_locale
    disable_org_orchestration

    Resources::Candlepin::Consumer.stubs(:create).returns({ :uuid => uuid, :owner => { :key => uuid } })
    Resources::Candlepin::Consumer.stubs(:update).returns(true)

    Katello.pulp_server.extensions.consumer.stubs(:create).returns({ :id => uuid })
    Katello.pulp_server.extensions.consumer.stubs(:update).returns(true)

    @organization  = Organization.create!(:name => 'test_org', :label => 'test_org')
    @environment_1 = create_environment(:name => 'test_1', :label => 'test_1', :prior => @organization.library.id, :organization => @organization)
    @system        = create_system(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
    System.stubs(:first).returns(@system)
  end

  describe "create a subscription" do
    let(:action) { :create }
    let(:req) { post :create, :system_id => @system.id, :pool => "poolidXYZ", :quantity => 1 }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it "requires pool and quantity to be specified", :katello => true do #TODO headpin
      post :create, :system_id => @system.id
      response.code.must_equal "400"
    end

    context "subscribes" do
      it "to one pool", :katello => true do #TODO headpin
        Resources::Candlepin::Consumer.expects(:consume_entitlement).once.with(@system.uuid, "poolidXYZ", "1")
        post :create, :system_id => @system.id, :pool => "poolidXYZ", :quantity => '1'
      end
    end

    context "unsubscribes" do
      it "from one pool", :katello => true do #TODO headpin
        Resources::Candlepin::Consumer.expects(:remove_entitlement).once.with(@system.uuid, "poolidXYZ")
        post :destroy, :system_id => @system.id, :id => "poolidXYZ"
      end

      it "from one pool by serial", :katello => true do #TODO headpin
        Resources::Candlepin::Consumer.expects(:remove_certificate).once.with(@system.uuid, "serialidXYZ")
        post :destroy_by_serial, :system_id => @system.id, :serial_id => "serialidXYZ"
      end

      it "from all pools", :katello => true do #TODO headpin
        Resources::Candlepin::Consumer.expects(:remove_entitlements).once.with(@system.uuid)
        post :destroy_all, :system_id => @system.id
      end
    end

    describe "list subscriptions" do
      let(:action) { :index }
      let(:req) { get :index, :system_id => @system.id }
      let(:authorized_user) { user_with_read_permissions }
      let(:unauthorized_user) { user_without_read_permissions }
      it_should_behave_like "protected action"

      it "should find System", :katello => true do #TODO heapdin
        System.expects(:first).once.with(has_entries(:conditions => { :uuid => @system.uuid })).returns(@system)
        get :index, :system_id => @system.uuid
      end

      it "should retrieve Consumer's errata from pulp", :katello => true do #TODO headpin
        Resources::Candlepin::Consumer.expects(:entitlements).once.with(uuid).returns([])
        get :index, :system_id => @system.uuid
      end
    end

  end
end
