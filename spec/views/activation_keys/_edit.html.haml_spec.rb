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

describe "activation_keys/_edit.html.haml" do
  before(:each) do
    @organization = assign(:organization, stub_model(Organization,
      :name => "Test Org"))

    @environment = assign(:environment, stub_model(KTEnvironment,
      :name => "dev").as_new_record)
    @environment.stub(:products).and_return([])
    @products = []

    @key_name = "New Key"
    @key_description = "This is a new activation key"

    @activation_key = assign(:activation_key, stub_model(ActivationKey,
      :name => @key_name,
      :description => @key_description,
      :organization => @organization
    ))

    view.should_receive(:name).any_number_of_times.and_return('activation_key')

    view.stub(:help_tip_button)
    view.stub(:help_tip)
    view.stub(:render_menu)
    view.stub(:editable).and_return(true)

    @content_view_labels = []
    @selected_content_view = "No Content View"
    view.stub!(:environment_selector)
    view.stub!(:activation_keys_navigation).and_return([])
    render :partial => "edit", :locals => {:accessible_envs => [@environment],
                                           :content_view_labels => @content_view_labels,
                                           :selected_content_view => @selected_content_view,
                                           :products => @products
                                          }
  end

  it "content_for :title is included" do
    view.content_for(:title).should_not be_nil
  end

  describe "content_for :remove_item" do
    it "is included" do
      view.content_for(:remove_item).should_not be_nil
    end

    it "renders link to destroy activation key" do
      view.content_for(:remove_item).should have_selector("a.remove_item", :count => 1)
    end
  end

  describe "content_for :navigation" do
    it "is included" do
      view.content_for(:navigation).should_not be_nil
    end

    it "renders sub-navigation links" do
      view.should_receive(:render_menu).with(1..2, []).once
      render :partial => "edit", :locals => {:accessible_envs => [@environment],
                                             :content_view_labels => @content_view_labels,
                                             :selected_content_view => @selected_content_view,
                                             :products => @products
                                            }
    end
  end

  describe "content_for :content" do
    it "is included" do
      view.content_for(:content).should_not be_nil
    end

    it "renders the activation key name using inline edit" do
      view.content_for(:content).should have_selector(".editable[name='activation_key[name]']", :count => 1)
    end

    it "renders the activation key description using inline edit" do
      view.content_for(:content).should have_selector(".editable[name='activation_key[description]']", :count => 1)
    end

    it "renders the activation key content view select", :katello => true do #TODO headpin
      view.content_for(:content).should have_selector("select#activation_key_content_view_id", :count => 1)
    end

    it "renders a box to display the products in the environment", :katello => true do
      view.content_for(:content).should have_selector("div.productsbox", :count => 1)
    end

    it "renders a save and cancel button for environment" do
      view.content_for(:content).should have_selector("#cancel_key", :count => 1)
      view.content_for(:content).should have_selector("input[type=submit]#save_key", :count => 1)
    end
  end
end
