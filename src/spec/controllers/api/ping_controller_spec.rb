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

describe Api::PingController do
  include LoginHelperMethods

  before (:each) do
    login_user
    @request.env["HTTP_ACCEPT"] = "application/json"
  end

  def resource_list
    get :resource_list
  end

  def json(response)
    JSON.parse(response.body)
  end

  context "in headpin mode" do
    before (:each) do
      Katello.config.stub!(:app_name).and_return("Headpin")
      Katello.config.stub!(:katello_version).and_return("12")
    end
    it "staus should reflect the correct information" do
      get :status
      json(response).should include "release" => "Headpin"
      json(response).should include "version" => "12"
    end
  end

  context "in katello mode" do

    before (:each) do
      Katello.config.stub!(:app_name).and_return("Katello")
      Katello.config.stub!(:katello_version).and_return("12")
    end
    it "staus should reflect the correct information" do
      get :status
      json(response).should include "release" => "Katello"
      json(response).should include "version" => "12"
    end
  end

end
