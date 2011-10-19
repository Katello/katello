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

describe DistributionsController do
  include LoginHelperMethods
  include LocaleHelperMethods

  before (:each) do
    login_user
    set_default_locale
    Glue::Pulp::Distribution.stub!(:find).and_return
  end

  describe "GET show" do
    it "should lookup the distribution" do
      Glue::Pulp::Distribution.should_receive(:find).once.with(10)
      get :show, :id => 10
    end

    it "renders show partial" do
      get :show, :id => 10
      response.should render_template(:partial => "_show")
    end

    it "should be successful" do
      get :show, :id => 10
      response.should be_success
    end
  end

  describe "GET filelist" do
    it "should lookup the distribution" do
      Glue::Pulp::Distribution.should_receive(:find).once.with(10)
      get :filelist, :id => 10
    end

    it "renders the file list partial" do
      get :filelist, :id => 10
      response.should render_template(:partial => "_filelist")
    end

    it "should be successful" do
      get :filelist, :id => 10
      response.should be_success
    end
  end

end
