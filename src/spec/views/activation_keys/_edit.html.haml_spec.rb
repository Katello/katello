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

describe "activation_keys/_edit.html.haml" do
  before(:each) do
    @organization = assign(:organization, stub_model(Organization,
      :name => "Test Org"))

    @key_name = "New Key"
    @key_description = "This is a new activation key"

    @activation_key = assign(:activation_key, stub_model(ActivationKey,
      :name => @key_name,
      :description => @key_description,
      :organization => @organization
    ))

    view.stub(:help_tip_button)
    view.stub(:help_tip)
    view.stub(:render_navigation)
    view.stub(:editable).and_return(true)

    view.stub_chain(:current_organization, :environments).and_return([])
  end

  it "content_for :title is included" do
    render
    view.content_for(:title).should_not be_nil
  end

  describe "content_for :remove_item" do
    it "is included" do
      render
      view.content_for(:remove_item).should_not be_nil
    end

    it "renders link to destroy activation key" do
      render
      view.content_for(:remove_item).should have_selector("a.remove_item", :count => 1)
    end
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

    it "renders the activation key name using inline edit" do
      render
      view.content_for(:content).should have_selector(".editable[name='activation_key[name]']", :count => 1)
    end

    it "renders the activation key description using inline edit" do
      render
      view.content_for(:content).should have_selector(".editable[name='activation_key[description]']", :count => 1)
    end

    it "renders the activation key system template using inline edit" do
      render
      view.content_for(:content).should have_selector(".editable[name='activation_key[system_template_id]']", :count => 1)
    end
  end
end
