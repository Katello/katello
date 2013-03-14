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
      @defs = FactoryGirl.create_list(:content_view_definition, 3,
                                      :organization => @organization)
    end

    let(:action) { :index }

    context "with organization_id" do
      it "should assign the organiation's definitions" do
        Organization.stub_chain(:without_deleting,
                                :having_name_or_label,:first).and_return(@organization)
        req = get action, :organization_id => @organization.name
        req.should be_success
        assigns[:definitions].map(&:id).should eql(@defs.map(&:id))
      end
    end

    context "with label" do
      it "should find the matching content view definition" do
        Organization.stub_chain(:without_deleting,
                                :having_name_or_label,:first).and_return(@organization)
        get action, :organization_id => @organization.name,
          :label => @defs.last.label
        assigns[:definitions].map(&:id).should eql([@defs.last.id])
      end
    end

    context "with id" do
      it "should find the matching definition" do
        cvd = @defs.sample
        Organization.stub_chain(:without_deleting,
                                :having_name_or_label,:first).and_return(@organization)
        get action, :organization_id => @organization.name,
          :id => cvd.id
        assigns[:definitions].map(&:id).should eql([cvd.id])
      end
    end

    context "with name" do
      it "should find the matching definitions" do
        Organization.stub_chain(:without_deleting,
                                :having_name_or_label,:first).and_return(@organization)
        defs = FactoryGirl.create_list(:content_view_definition, 2,
                                       :organization => @organization)
        view = ContentViewDefinition.last
        get action, :organization_id => @organization.name, :name => view.name
        assigns[:definitions].length.should eql(1)
        assigns[:definitions].map(&:id).should eql([view.id])
      end
    end
  end

  describe "publish" do
    before do
      @organization = FactoryGirl.create(:organization)
      Organization.stub(:first).and_return(@organization)
      FactoryGirl.create_list(:content_view_definition, 2, :organization => @organization)
    end
    let(:definition) { @organization.content_view_definitions.last }

    it "should create a content view" do
      Organization.stub_chain(:without_deleting,
                              :having_name_or_label,:first).and_return(@organization)
      cv_count = ContentView.count
      req = post :publish, :id => definition.id,
        :organization_id => @organization.id, :name => "TestView"
      req.should be_success
      ContentView.count.should eql(cv_count + 1)
    end
  end

  describe "destroy" do
    it "should delete the definition after checking it has no promoted views" do
      definition = FactoryGirl.build_stubbed(:content_view_definition)
      ContentViewDefinition.stub(:find).with(definition.id.to_s).and_return(definition)
      definition.should_receive(:destroy).and_return(true)
      definition.should_receive(:has_promoted_views?).and_return(false)
      delete :destroy, :id => definition.id.to_s
      response.should be_success
    end
  end

  describe "update" do
    it "should not allow me to change the definition's org" do
      org1 = FactoryGirl.create(:organization)
      org2 = FactoryGirl.create(:organization)
      content_view_definition = FactoryGirl.create(:content_view_definition,
                                                   :organization => org1
                                                  )
      put :update, :id => content_view_definition.id, :organization_id => org1.id,
        :content_view_definition => {:organization_id => org2.id}
      content_view_definition.reload.organization_id.should_not eql(org2.id)
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
