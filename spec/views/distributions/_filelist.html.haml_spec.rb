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

describe "distributions/_filelist.html.haml", :katello => true do
  before(:each) do
    view.stub(:render_menu)
    view.stub(:promotion_distribution_navigation).and_return([])
    @files = [ { 'relativepath' => "/path/to/file/in/distribution" } ]
    @distribution = Distribution.new()
    @distribution = mock(Distribution, { "id" => "ks-Red Hat Enterprise Linux-Server-6.4-x86_64",
                                         '_id' => "0b74d908-5b95-4315-a925-d3e97fd058f2" })

    @distribution.stub!(:files).and_return(@files)
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
      view.should_receive(:render_menu).with(1..2, []).once
      render
    end
  end

  describe "content_for :content" do
    it "is included" do
      render
      view.content_for(:content).should_not be_nil
    end

    it "renders the files in the distribution" do
      render
      view.content_for(:content).should have_selector(".distribution", :count => 1, :content => @filename)
    end
  end
end
