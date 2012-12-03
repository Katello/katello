# encoding: utf-8
#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "minitest_helper"

describe Api::ContentViewsController do
  fixtures :all

  describe "#promote" do
    before do
      @content_view = content_views(:library_dev_view)
      @environment = environments(:staging)
      login_user(users(:admin))
    end

    it "should throw an error if environment_id is nil" do
      post :promote, :id => @content_view.id
      response.status.wont_equal 200
    end

    it "should assign a content view" do
      post :promote, :id => @content_view.id, :environment_id => @environment.id
      response.success?.must_equal true
      content_view = assigns(:view)
      content_view.wont_be_nil
      content_view.must_equal @content_view
    end

    it "should assign a prior environment" do
      post :promote, :id => @content_view.id, :environment_id => @environment.id
      assigns(:prior).must_equal @environment.prior
      assigns(:prior).must_equal environments(:library)
    end

    it "should throw an error if view is already in env" do
      post :promote, :id => @content_view.id, :environment_id => environments(:dev).id
      response.status.must_equal 500
    end

  end

end
