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

require "spec_helper"

describe EnvironmentsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/organizations/1/environments" }.should route_to(:controller => "environments", :action => "index", :organization_id =>"1")
    end

    it "recognizes and generates #new" do
      { :get => "/organizations/1/environments/new" }.should route_to(:controller => "environments", :action => "new", :organization_id =>"1")
    end

    it "recognizes and generates #show" do
      { :get => "/organizations/1/environments/1" }.should route_to(:controller => "environments", :action => "show", :id => "1", :organization_id =>"1")
    end

    it "recognizes and generates #edit" do
      { :get => "/organizations/1/environments/1/edit" }.should route_to(:controller => "environments", :action => "edit", :id => "1", :organization_id =>"1")
    end

    it "recognizes and generates #create" do
      { :post => "/organizations/1/environments" }.should route_to(:controller => "environments", :action => "create", :organization_id =>"1")
    end

    it "recognizes and generates #update" do
      { :put => "/organizations/1/environments/1" }.should route_to(:controller => "environments", :action => "update", :id => "1", :organization_id =>"1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/organizations/1/environments/1" }.should route_to(:controller => "environments", :action => "destroy", :id => "1", :organization_id =>"1")
    end

  end
end
