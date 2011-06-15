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

describe "routing to login" do
  it "routes /login to user_sessions#new" do
    { :get => "/login" }.should route_to(
      :controller => "user_sessions",
      :action => "new"
    )
  end

  it "routes /logout to user_sessions#destroy" do
    { :get => "/logout" }.should route_to(
      :controller => "user_sessions",
      :action => "destroy"
    )
  end
end
