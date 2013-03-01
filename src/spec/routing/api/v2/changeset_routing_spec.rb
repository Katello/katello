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

describe Api::V1::ChangesetsController do
  describe "routing" do

    let(:cs_controller) { "api/v1/changesets" }

    it {{ :get => "/api/changesets/1" }.should route_to(:controller => cs_controller, :action => "show", :id => "1")}
    it {{ :put => "/api/changesets/1" }.should route_to(:controller => cs_controller, :action => "update", :id => "1")}
    it {{ :delete => "/api/changesets/1" }.should route_to(:controller => cs_controller, :action => "destroy", :id => "1")}
    it {{ :post => "/api/changesets/1/apply" }.should route_to(:controller => cs_controller, :action => "apply", :id => "1")}
    it {{ :get => "/api/changesets/1/dependencies" }.should route_to(:controller => cs_controller, :action => "dependencies", :id => "1")}

  end
end
