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

describe "activation_keys/_new.html.haml" do
  before(:each) do
    @environment = assign(:environment, stub_model(KTEnvironment,
      :name => "dev").as_new_record)

    @key_name = "New Key"
    @key_description = "This is a new activation key"
    @activation_key = assign(:activation_key, stub_model(ActivationKey,
      :name => @key_name,
      :description => @key_description
    ).as_new_record)

    @system_template_labels = []
    @selected_template = "No Template"
    @content_view_labels = []
    @selected_content_view = "No Content View"
    view.stub!(:environment_selector)

    render :partial => "new", :locals => {:accessible_envs => [@environment]}
  end

  it "content_for :title is included" do
    view.content_for(:title).should_not be_nil
  end

  describe "content_for :content" do
    it "is included" do
      view.content_for(:content).should_not be_nil
    end

    it "should include key details", :katello => true do #TODO headpin
      view.content_for(:content).should have_selector("input#activation_key_name", :count => 1)
      view.content_for(:content).should have_selector("textarea#activation_key_description", :count => 1)
      view.content_for(:content).should have_selector("input#activation_key_environment_id", :count => 1)
      view.content_for(:content).should have_selector("select#activation_key_content_view_id", :count => 1)
    end

    it "should include button to save the new key" do
      view.content_for(:content).should have_selector("input[type=submit]#save_key", :count => 1)
    end
  end

end
