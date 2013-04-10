#
# Copyright 2013 Red Hat, Inc.
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

describe DashboardController do
  include LoginHelperMethods
  include LocaleHelperMethods

  before (:each) do
    login_user
    set_default_locale
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET system_groups" do
    it "should be successful" do
      get 'system_groups'
      response.should be_success
    end

    it "should render system groups partial" do
      get 'system_groups'
      response.should render_template(:partial => "_system_groups")
    end
  end

  describe "GET content_views" do
    it "should be successful" do
      get 'content_views'
      response.should be_success
    end

    it "should render content views partial" do
      get 'content_views'
      response.should render_template(:partial => "_content_views")
    end
  end

end
