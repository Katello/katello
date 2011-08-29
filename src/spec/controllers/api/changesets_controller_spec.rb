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

require 'spec_helper.rb'

describe Api::ChangesetsController do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper

  CSET_ID = 1
  CSET_NAME = "changeset_x"

  let(:uuid) { '1234' }

  before(:each) do
    disable_org_orchestration

    @organization = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
    @environment = KTEnvironment.create!(:name => 'test_1', :prior => @organization.locker.id, :organization => @organization)
    @environment_2 = KTEnvironment.create!(:name => 'test_2', :prior => @environment, :organization => @organization)
    KTEnvironment.stub(:find).and_return(@environment)

    @changeset = mock(Changeset)
    @changeset.stub(:environment).and_return(@environment)
    @changeset.stub(:environment=)
    @changeset.stub(:state=)
    @changeset.stub(:save!)
    @changeset.stub(:async).and_return(@changeset)
    @changeset.stub(:promote)
    Changeset.stub(:find).and_return(@changeset)

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  let(:to_create) do
    {
      :name => CSET_NAME
    }
  end

  let(:user_with_read_permissions) do
    user_with_permissions { |u| u.can(:read_changesets,:environments, @environment.id, @organization) }
  end
  let(:user_without_read_permissions) do
    user_with_permissions { |u| u.can(:read_changesets,:environments, @environment_2.id, @organization) }
  end
  let(:user_with_manage_permissions) do
    user_with_permissions { |u| u.can([:manage_changesets],:environments, @environment.id, @organization) }
  end
  let(:user_without_manage_permissions) do
    user_with_permissions { |u| u.can(:read_changesets,:environments, @environment.id, @organization) }
  end
  let(:user_with_promote_permissions) do
    user_with_permissions { |u| u.can([:promote_changesets],:environments, @environment.id, @organization) }
  end
  let(:user_without_promote_permissions) do
    user_without_permissions
    # user_with_permissions { |u| u.can([:manage_changesets],:environments, @environment.id, @organization) }
  end

  describe "index" do

    let(:action) {:index }
    let(:req) { get :index, :organization_id => "1", :environment_id => 1 }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it 'should call working_changesets on an environment' do
      Changeset.should_receive(:select).once
      req
    end
  end


  describe "show" do

    let(:action) {:show }
    let(:req) { get :show, :id => CSET_ID, :organization_id => "1", :environment_id => 1 }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should call Changeset.first" do
      Changeset.should_receive(:find).with(CSET_ID).and_return(@changeset)
      req
    end
  end


  describe "create" do

    let(:action) {:create }
    let(:req) { post :create, :changeset => {'name' => 'XXX'}, :organization_id => "1", :environment_id => 1 }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should call new and save!" do
      Changeset.should_receive(:new).and_return(@changeset)
      @changeset.should_receive(:save!)

      req
    end
  end


  describe "update_content" do

    let(:action) {:update_content }
    let(:req) { put :update_content, :id => CSET_ID, :organization_id => "1", :environment_id => 1, :patch => {'+products' => ['prod']}}
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it 'should call add_product' do
      @changeset.should_receive(:add_product).with('prod').once
      put :update_content, :id => CSET_ID, :organization_id => "1", :environment_id => 1, :patch => {'+products' => ['prod']}
    end

    it 'should call remove_product' do
      @changeset.should_receive(:remove_product).with('prod').once
      put :update_content, :id => CSET_ID, :organization_id => "1", :environment_id => 1, :patch => {'-products' => ['prod']}
    end

    it 'should call add_package' do
      @changeset.should_receive(:add_package).with('pack', 'prod').once
      put :update_content, :id => CSET_ID, :organization_id => "1", :environment_id => 1, :patch => {'+packages' => [{:name => 'pack', :product => 'prod'}]}
    end

    it 'should call remove_package' do
      @changeset.should_receive(:remove_package).with('pack', 'prod').once
      put :update_content, :id => CSET_ID, :organization_id => "1", :environment_id => 1, :patch => {'-packages' => [{:name => 'pack', :product => 'prod'}]}
    end

    it 'should call add_erratum' do
      @changeset.should_receive(:add_erratum).with('err', 'prod').once
      put :update_content, :id => CSET_ID, :organization_id => "1", :environment_id => 1, :patch => {'+errata' => [{:name => 'err', :product => 'prod'}]}
    end

    it 'should call remove_erratum' do
      @changeset.should_receive(:remove_erratum).with('err', 'prod').once
      put :update_content, :id => CSET_ID, :organization_id => "1", :environment_id => 1, :patch => {'-errata' => [{:name => 'err', :product => 'prod'}]}
    end

    it 'should call add_repo' do
      @changeset.should_receive(:add_repo).with('repo', 'prod').once
      put :update_content, :id => CSET_ID, :organization_id => "1", :environment_id => 1, :patch => {'+repos' => [{:name => 'repo', :product => 'prod'}]}
    end

    it 'should call remove_repo' do
      @changeset.should_receive(:remove_repo).with('repo', 'prod').once
      put :update_content, :id => CSET_ID, :organization_id => "1", :environment_id => 1, :patch => {'-repos' => [{:name => 'repo', :product => 'prod'}]}
    end

  end

  describe "destroy" do

    let(:action) {:destroy }
    let(:req) { delete :destroy, :id => CSET_ID, :organization_id => "1", :environment_id => 1}
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should remove the changeset" do
      Changeset.should_receive(:find).with(CSET_ID).and_return(@changeset)
      @changeset.should_receive(:destroy).once

      req
    end
  end

  describe "promote" do

    let(:action) {:promote }
    let(:req) { post :promote, :id => CSET_ID, :organization_id => "1", :environment_id => 1 }
    let(:authorized_user) { user_with_promote_permissions }
    let(:unauthorized_user) { user_without_promote_permissions }
    it_should_behave_like "protected action"

    it "should call Changeset.promote asynchronously" do
      @changeset.should_receive(:promote).once
      @changeset.should_receive(:async).once
      req
    end
  end

end
