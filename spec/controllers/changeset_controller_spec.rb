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

describe ChangesetsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods


  module CSControllerTest
    ENV_NAME = "environment_name"
    ENVIRONMENT = {:id => 1, :name => ENV_NAME, :description => nil, :prior => nil}
    CHANGESET = {:id=>1, :promotion_date=>Time.now, :name=>"oldname",
                 :packages=>[ChangesetPackage.new({:display_name=>"foo-1.2.3", :package_id=>"123"})],
                 :errata=>[ChangesetErratum.new({:display_name=>"RHSA-2011-23-2", :id=>"123"})]}
    
  end

  before(:each) do
    login_user
    set_default_locale
    controller.stub!(:notice)
    controller.stub!(:errors)

    @org = new_test_org 

    CSControllerTest::ENVIRONMENT["organization"] = @org
    @env = KPEnvironment.create(CSControllerTest::ENVIRONMENT)

    CSControllerTest::CHANGESET["environment"] = @env
    @changeset = Changeset.create(CSControllerTest::CHANGESET)
  end


  describe "viewing changesets" do

    it "should show the changeset 2 pane list" do
      get :index
      response.should be_success
    end

    it "changesetuser should be empty" do
      get :index
      @changeset.users.should be_empty
    end

    it "should return a portion of changesets for an environment" do
      get :items
      response.should be_success
    end

    it "should be able to list changesets for an environment" do
      get :list, :env_id=>@env.id
      response.should be_success
    end

    it "should be able to show the edit partial" do
      get :edit, :id=>@changeset.id
      response.should be_success
    end

    it "should be able to update the name of a changeset" do
      post :update, :id=>@changeset.id, :name=>"newname"
      response.should be_success
      Changeset.find(@changeset.id).name.should == "newname"
    end

    it "should allow viewing the dependency size" do
      get :dependency_size, :id=>@changeset.id
      response.should be_success
    end
    
  end

end
