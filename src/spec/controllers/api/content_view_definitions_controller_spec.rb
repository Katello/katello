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

describe Api::ContentViewDefinitionsController, :katello => true do
  include LoginHelperMethods
  include AuthorizationHelperMethods

  before(:each) do
    disable_org_orchestration
    disable_product_orchestration
    disable_user_orchestration

    @organization = FactoryGirl.build_stubbed(:organization)

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  describe "index" do
    before do
      Organization.stub(:first).and_return(@organization)
      @defs = FactoryGirl.build_list(:content_view_definition, 2)
      @defs << FactoryGirl.build(:content_view_definition, :label => "test")
    end

    let(:action) { :index }

    context "with organization_id" do
      it "should assign the organiation's definitions" do
        ContentViewDefinition.should_receive(:where).
          with(:organization_id => @organization.id).and_return(@defs)
        req = get action, :organization_id => @organization.name
        req.should be_success
        assigns[:definitions].should eql(@defs)
      end
    end

    context "with label" do
      it "should find the matching content view definition" do
        scope = Object.new
        scope.should_receive(:where).with(:label => @defs.last.label).
          and_return([@defs.last])

        ContentViewDefinition.should_receive(:readable).with(@organization).
          and_return(scope)

        get action, :organization_id => @organization.name,
          :label => @defs.last.label
        assigns[:definitions].should eql([@defs.last])
      end
    end
  end

  describe "publish" do
    before do
      Organization.stub(:first).and_return(@organization)
      @organization.content_view_definitions =
        FactoryGirl.build_list(:content_view_definition, 2)
    end
    let(:definition) { @organization.content_view_definitions.last }

    it "should create a content view" do
      cv_count = ContentView.count
      req = post :publish, :id => definition.id,
        :organization_id => @organization.id, :name => "TestView"
      req.should be_success
      ContentView.count.should eql(cv_count + 1)
    end
  end

  describe "destroy" do
    it "should delete the definition from the database" do
      definition = FactoryGirl.create(:content_view_definition)
      expect { delete :destroy, :id => definition.id }.to change(
        ContentViewDefinition, :count).by(-1)
    end
  end

  describe "update_content_views" do
    let(:definition) { FactoryGirl.create(:content_view_definition) }
    let(:views) { FactoryGirl.create_list(:content_view, 2) }
    let(:req) { put :update_content_views, :id => definition.id, :views =>
      views.map(&:id) }
    subject { req and definition.component_content_views.reload }
    its(:length) { should eql(2) }
  end

end
