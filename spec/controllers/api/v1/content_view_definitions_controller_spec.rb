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

require 'katello_test_helper'

module Katello
  describe Api::V1::ContentViewDefinitionsController do
    describe "(katello)" do
      include LoginHelperMethods
      include AuthorizationHelperMethods
      include OrganizationHelperMethods

      before(:each) do
        disable_org_orchestration
        disable_product_orchestration
        disable_user_orchestration

        @organization = FactoryGirl.build_stubbed(:organization)

        @request.env["HTTP_ACCEPT"] = "application/json"
        setup_controller_defaults_api
      end

      describe "index" do
        before do
          @defs = FactoryGirl.create_list(:content_view_definition, 3,
                                          :organization => @organization)
        end

        let(:action) { :index }

        context "with organization_id" do
          it "should assign the organiation's definitions" do
            Organization.stubs(:without_deleting).returns(stub(:having_name_or_label =>
                                                               stub(:first => @organization)))
            req = get action, :organization_id => @organization.name
            must_respond_with(:success)
            assigns[:definitions].map(&:id).must_equal(@defs.map(&:id))
          end
        end

        context "with label" do
          it "should find the matching content view definition" do
            Organization.stubs(:without_deleting).returns(stub(:having_name_or_label =>
                                                               stub(:first => @organization)))
            get action, :organization_id => @organization.name,
              :label                   => @defs.last.label
            assigns[:definitions].map(&:id).must_equal([@defs.last.id])
          end
        end

        context "with id" do
          it "should find the matching definition" do
            cvd = @defs.sample
            Organization.stubs(:without_deleting).returns(stub(:having_name_or_label =>
                                                               stub(:first => @organization)))
            get action, :organization_id => @organization.name,
              :id                      => cvd.id
            assigns[:definitions].map(&:id).must_equal([cvd.id])
          end
        end

        context "with name" do
          it "should find the matching definitions" do
            Organization.stubs(:without_deleting).returns(stub(:having_name_or_label =>
                                                               stub(:first => @organization)))
            defs = FactoryGirl.create_list(:content_view_definition, 2,
                                           :organization => @organization)
            view = ContentViewDefinition.last
            get action, :organization_id => @organization.name, :name => view.name
            assigns[:definitions].length.must_equal(1)
            assigns[:definitions].map(&:id).must_equal([view.id])
          end
        end
      end

      describe "publish" do
        before do
          @organization = FactoryGirl.create(:organization)
          FactoryGirl.create_list(:content_view_definition, 2, :organization => @organization)
        end
        let(:definition) { @organization.content_view_definitions.last }

        it "should create a content view" do
          Organization.stubs(:without_deleting).returns(stub(:having_name_or_label =>
                                                             stub(:first => @organization)))
          cv_count = ContentView.count
          req      = post :publish, :id    => definition.id,
            :organization_id => @organization.id, :name => "TestView"
          must_respond_with(:success)
          ContentView.count.must_equal(cv_count + 1)
        end
      end

      describe "create" do
        it "should create a composite definition if composite is supplied" do
          Organization.stubs(:without_deleting).returns(stub(:having_name_or_label =>
                                                             stub(:first => @organization)))
          post :create, content_view_definition: { name: "Test", composite: 1 },
            organization_id:                  @organization.id
          must_respond_with(:success)
          ContentViewDefinition.last.must_be :composite?
        end
      end

      describe "destroy" do
        it "should delete the definition after checking it has no promoted views" do
          definition = FactoryGirl.build_stubbed(:content_view_definition)
          ContentViewDefinition.stubs(:find).with(definition.id.to_s).returns(definition)
          definition.expects(:destroy).returns(true)
          definition.expects(:has_promoted_views?).returns(false)
          delete :destroy, :id => definition.id.to_s
          must_respond_with(:success)
        end
      end

      describe "update" do
        it "should not allow me to change the definition's org" do
          org1                    = FactoryGirl.create(:organization)
          org2                    = FactoryGirl.create(:organization)
          content_view_definition = FactoryGirl.create(:content_view_definition,
                                                       :organization => org1
                                                      )
          put :update, :id             => content_view_definition.id, :organization_id => org1.id,
            :content_view_definition => { :organization_id => org2.id }
          content_view_definition.reload.organization_id.wont_equal(org2.id)
        end
      end

      describe "update_content_views" do
        it "should update the definition's components" do
          definition = FactoryGirl.create(:content_view_definition, :composite)
          views      = FactoryGirl.create_list(:content_view, 2)
          ContentView.stubs(:readable).returns(stub(:where => views))
          put :update_content_views, :id => definition.id, :views => views.map(&:id)
          definition.component_content_views.reload.length.must_equal(2)
        end
      end

    end
  end
end
