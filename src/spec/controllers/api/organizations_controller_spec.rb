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

  before(:each) do
    @org = Organization.new
    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  describe "create a root org" do
    it 'should call kalpana create organization api' do
      Organization.should_receive(:create!).once.with(:name => 'test org', :description => 'description', :cp_key => 'test_org').and_return(@org)
      post 'create', :name => 'test org', :description => 'description'
    end
  end
  
  describe "get a listing of organizations" do
    it 'should call katello organization find api' do
      Organization.should_receive(:where).once
      get 'index'
    end 
  end
  
  describe "show a organization" do
    it 'should call katello organization find api' do
      Organization.should_receive(:first).once.with(:conditions => {:cp_key => "spec"})
      get 'show', :id => "spec"
    end
  end

  describe "show a organization" do
    it 'should call katello organization find api and account for spaces in search name' do
      Organization.should_receive(:first).once.with(:conditions => {:cp_key => "show_org_with_spaces"})
      get 'show', :id => "show org with spaces"
    end
  end

  describe "delete a organization" do    
    it 'should call organization destroy method' do
      Organization.should_receive(:first).once.with(:conditions => {:cp_key => "spec"}).and_return(@org)
      @org.should_receive(:destroy).once
      delete 'destroy', :id => "spec"
    end
  end

  describe "delete a organization" do
    it 'should call organization destroy method while accounting for spaces in search name' do
      Organization.should_receive(:first).once.with(:conditions => {:cp_key => "delete_org_with_spaces"}).and_return(@org)
      @org.should_receive(:destroy).once
      delete 'destroy', :id => "delete org with spaces"
    end
  end

  describe "update a organization" do
    it 'should call org update_attributes' do
      Organization.should_receive(:first).once.with(:conditions => {:cp_key => "spec"}).and_return(@org)
      @org.should_receive(:update_attributes!).once
      put 'update', :id => "spec"
    end
  end

  describe "update a organization" do
    it 'should call org update_attributes while accounting for spaces in the search name' do
      Organization.should_receive(:first).once.with(:conditions => {:cp_key => "update_org_with_spaces"}).and_return(@org)
      @org.should_receive(:update_attributes!).once
      put 'update', :id => "update org with spaces"
    end
  end
end
