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

describe Api::EnvironmentsController do
  include LoginHelperMethods

  before (:each) do
    @org         = Organization.new(:cp_key => "1")
    @environment = KPEnvironment.new
    Organization.stub!(:first).and_return(@org)
    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  describe "create an environment" do
    before (:each) do
      KPEnvironment.should_receive(:new).once.and_return(@environment)
      @org.should_receive(:save!).once
    end

    it 'should call katello create environment api' do
      post 'create', :organization_id => "1", :environment => {:name => "production", :description =>"a"}
    end
  end

  describe "get a listing of environments" do
    it 'should call kalpana environment find api' do
      KPEnvironment.should_receive(:where).once
      get 'index', :organization_id => "1"
    end
  end

  describe "show a environment" do
    it 'should call KPEnvironment.first' do
      KPEnvironment.should_receive(:find).once().and_return(@environment)
      get 'show', :id => 1, :organization_id => "1"
    end
  end

  describe "delete a environment" do
    before (:each) do
      KPEnvironment.should_receive(:find).once().and_return(@environment)
    end

    it 'should call katello environment find api' do
        @environment.should_receive(:destroy).once
        delete 'destroy', :id => 1 , :organization_id => "1"
    end
  end

  describe "update an environment" do
    it 'should call KPEnvironment update_attributes' do
      KPEnvironment.should_receive(:find).once().and_return(@environment)
      @environment.should_receive(:update_attributes!).once.and_return(@environment)
      put 'update', :id => 'to_update', :organization_id => "1"
    end
  end

end
