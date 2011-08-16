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

describe "distributions/_show.html.haml" do
  before(:each) do
    view.stub(:render_navigation)

    @id = "distro-id-1"
    @description = "this is distro 1"
    @distribution = Glue::Pulp::Distribution.new()
    @distribution.stub!(:id).and_return(@id)
    @distribution.stub!(:description).and_return(@description)
  end

  it "content_for :title is included" do
    render
    view.content_for(:title).should_not be_nil
  end

  describe "content_for :navigation" do
    it "is included" do
      render
      view.content_for(:navigation).should_not be_nil
    end

    it "renders sub-navigation links" do
      view.should_receive(:render_navigation).with(:expand_all => true, :level => 3).once
      render
    end
  end

  describe "content_for :content" do
    it "is included" do
      render
      view.content_for(:content).should_not be_nil
    end

    it "renders the distribution name" do
      render
      view.content_for(:content).should have_selector("label", :count => 1, :content => "Name")
      view.content_for(:content).should have_selector("div", :count => 1, :content => @id)
    end

    it "renders the distribution description" do
      render
      view.content_for(:content).should have_selector("label", :count => 1, :content => "Description")
      view.content_for(:content).should have_selector("div", :count => 1, :content => @description)
    end
  end
end
