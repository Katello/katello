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

describe Api::OrganizationsController do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include OrganizationHelperMethods
  include LocaleHelperMethods

  let(:user_with_index_permissions) { user_with_permissions { |u| u.can([:read], :organizations) } }
  let(:user_without_index_permissions) { user_without_permissions }
  let(:user_with_read_permissions) { user_with_permissions { |u| u.can(Organization::READ_PERM_VERBS, :organizations) } }
  let(:user_without_read_permissions) { user_without_permissions }
  let(:user_with_create_permissions) { user_with_permissions { |u| u.can([:create], :organizations) } }
  let(:user_without_create_permissions) { user_with_permissions { |u| u.can([:update], :organizations) } }
  let(:user_with_update_permissions) { user_with_permissions { |u| u.can([:create], :organizations) } }
  let(:user_without_update_permissions) { user_without_permissions }
  let(:user_with_destroy_permissions) { user_with_permissions { |u| u.can([:delete], :organizations) } }
  let(:user_without_destroy_permissions) { user_with_permissions { |u| u.can([:update], :organizations) } }



  before(:each) do
    @organization = @org = new_test_org
    Organization.stub(:first => @org)
    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
    set_default_locale
  end

  describe "create a root org" do

    let(:action) {:create}
    let(:req) { post 'create', :name => 'test org', :description => 'description' }
    let(:authorized_user) { user_with_create_permissions }
    let(:unauthorized_user) { user_without_create_permissions }
    it_should_behave_like "protected action"

    it 'should call katello create organization api' do
      Organization.should_receive(:create!).once.with(:name => 'test org', :description => 'description', :label => 'test_org').and_return(@org)
      Organization.first(:conditions => {:label => 'test_org'}).should_not be_nil
      req
    end
  end

  describe "create a org with missing label from POST and name converted to label" do

    let(:action) {:create}
    let(:req) { post 'create', :name => 'test org with spaces', :description => 'description' }
    let(:authorized_user) { user_with_create_permissions }
    let(:unauthorized_user) { user_without_create_permissions }
    it_should_behave_like "protected action"

    it 'should call katello create organization api' do
      Organization.should_receive(:create!).once.with(:name => 'test org with spaces', :description => 'description',
                                                      :label => 'test_org_with_spaces').and_return(@org)
      Organization.first(:conditions => {:label => 'test_org_with_spaces'}).should_not be_nil
      req
    end
  end

  describe "create a org with label not equal to the name" do

    let(:action) {:create}
    let(:req) { post 'create', :name => 'test org', :description => 'description', :label => "some_other_label" }
    let(:authorized_user) { user_with_create_permissions }
    let(:unauthorized_user) { user_without_create_permissions }
    it_should_behave_like "protected action"

    it 'should call katello create organization api' do
      Organization.should_receive(:create!).once.with(:name => 'test org', :description => 'description',
                                                      :label => 'some_other_label').and_return(@org)
      Organization.first(:conditions => {:label => 'some_other_label'}).should_not be_nil
      req
    end
  end

  describe "get a listing of organizations" do

    let(:action) {:index}
    let(:req) { get 'index' }
    let(:authorized_user) { user_with_index_permissions }
    let(:unauthorized_user) { user_without_index_permissions }
    it_should_behave_like "protected action"

    it 'should call katello organization find api' do
      Organization.should_receive(:without_deleting).at_least(:once).and_return(Organization)
      Organization.should_receive(:readable).at_least(:once).and_return(Organization)
      Organization.should_receive(:where).once
      req
    end
  end

  describe "show a organization" do

    let(:action) {:show }
    let(:req) { get 'show', :id => "spec" }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it 'should call katello organization find api' do
      Organization.should_receive(:first).once.with(:conditions => {:name => "spec"})
      req
    end
  end

  describe "show a organization" do
    it 'should call katello organization find api and account for spaces in search name' do
      Organization.should_receive(:first).once.with(:conditions => {:name => "show org with spaces"})
      get 'show', :id => "show org with spaces"
    end
  end

  describe "delete a organization" do

    let(:action) {:destroy }
    let(:req) { delete 'destroy', :id => "spec" }
    let(:authorized_user) { user_with_destroy_permissions }
    let(:unauthorized_user) { user_without_destroy_permissions }
    it_should_behave_like "protected action"

   it 'should call organization destroy method' do
      Organization.should_receive(:first).once.with(:conditions => {:name => "spec"}).and_return(@org)
      OrganizationDestroyer.should_receive(:destroy).with(@org).once
      req
    end
  end

  describe "delete a organization" do
    it 'should call organization destroy method while accounting for spaces in search name' do
      Organization.should_receive(:first).once.with(:conditions => {:name => "delete org with spaces"}).and_return(@org)
      OrganizationDestroyer.should_receive(:destroy).with(@org).once
      delete 'destroy', :id => "delete org with spaces"
    end
  end

  describe "update a organization" do

    let(:action) {:update }
    let(:req) { put 'update', :id => "spec", :organization=>{:description=>"bah"} }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it 'should call org update_attributes' do
      Organization.should_receive(:first).once.with(:conditions => {:name => "spec"}).and_return(@org)
      @org.should_receive(:update_attributes!).once
      put 'update', :id => "spec", :organization=>{:description=>"bah"}
    end
  end

  describe "update a organization" do
    it 'should call org update_attributes while accounting for spaces in the search name' do
      Organization.should_receive(:first).once.with(:conditions => {:name => "update org with spaces"}).and_return(@org)
      @org.should_receive(:update_attributes!).once
      put 'update', :id => "update org with spaces", :organization=>{:description=>"bah"}
    end
    it_should_behave_like "bad request"  do
      let(:req) do
        bad_req = {:id => 123,
                   :organization =>
                      {:bad_foo => "mwahahaha",
                       :name => "Gpg Key",
                       :description => "This is the key string" }
        }.with_indifferent_access
        put :update, bad_req
      end
    end
  end
end
