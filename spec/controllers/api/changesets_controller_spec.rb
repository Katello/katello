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

  CSET_ID = 1
  CSET_NAME = "changeset_x"

  before(:each) do
    @environment = mock(KPEnvironment)
    @environment.stub(:id).and_return(1)

    KPEnvironment.stub(:find).and_return(@environment)

    @organization = mock(Organization)
    @organization.stub(:id).and_return(1)
    @organization.stub(:locker).and_return(@environment)
    @organization.stub(:environments).and_return([@environment])
    @environment.stub(:organization).and_return(@organization)

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

  describe "index" do
    it 'should call working_changesets on an environment' do
      Changeset.should_receive(:select).once
      get :index, :organization_id => "1", :environment_id => 1
    end
  end


  describe "show" do
    it "should call Changeset.first" do
      Changeset.should_receive(:find).with(CSET_ID).and_return(@changeset)
      get :show, :id => CSET_ID, :organization_id => "1", :environment_id => 1
    end
  end


  describe "create" do
    it "should call new and save!" do

      Changeset.should_receive(:new).and_return(@changeset)
      @changeset.should_receive(:save!)

      post :create, :changeset => {'name' => 'XXX'}, :organization_id => "1", :environment_id => 1
    end
  end


  describe "update_content" do

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
    it "should remove the changeset" do
      Changeset.should_receive(:find).with(CSET_ID).and_return(@changeset)
      @changeset.should_receive(:destroy).once

      delete :destroy, :id => CSET_ID, :organization_id => "1", :environment_id => 1
    end
  end

  describe "promote" do
    it "should call Changeset.promote asynchronously" do
      @changeset.should_receive(:promote).once
      @changeset.should_receive(:async).once
      post :promote, :id => CSET_ID, :organization_id => "1", :environment_id => 1
    end
  end

end
