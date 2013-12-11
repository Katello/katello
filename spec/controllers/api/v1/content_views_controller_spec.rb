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
  describe Api::V1::ContentViewsController do
    describe "(katello)" do
      include LoginHelperMethods
      include AuthorizationHelperMethods
      include OrganizationHelperMethods

      before(:each) do
        disable_org_orchestration
        disable_product_orchestration
        disable_user_orchestration

        @org                        = FactoryGirl.create(:organization)
        @request.env["HTTP_ACCEPT"] = "application/json"
        setup_controller_defaults_api
      end

      describe "index" do
        before do
          @content_views = FactoryGirl.create_list(:content_view, 4,
                                                   :organization => @org)
        end

        context "with no filter params" do
          let(:req) { get 'index', :organization_id => @org.name }
          let(:org_view_ids) { @org.content_views.map(&:id) }

          subject { req }
          it { req.must_respond_with(:success) }

          specify { subject && assigns[:content_views].map(&:id).must_equal(org_view_ids) }
        end

        context "with environment filter param" do
          it "should return only the environment's views" do
            env          = @org.environments.first || create_environment(:name            => "Test",
                                                                         :library         => false,
                                                                         :priors          => [@org.library],
                                                                         :organization_id => @org.id
                                                                        )
            view_version = ContentViewVersion.new(:version => 1, :content_view => @content_views.last)
            view_version.environments << env
            view_version.save!

            get "index", :organization_id => @org.name, :environment_id => env.id
            must_respond_with(:success)
            ids = env.content_views(true).map(&:id)
            assigns[:content_views].map(&:id).sort.must_equal(ids.sort)
          end
        end

        [:id, :name, :label].each do |param|

          context "with filter param #{param}" do
            let(:view) { @content_views.sample }
            let(:req) { get 'index', :organization_id => @org.name, param => view.send(param) }

            subject { req }

            it { req.must_respond_with(:success) }
            specify { subject && (assigns[:content_views].map(&:id).must_equal([view.id])) }
          end

        end
      end

      describe "refresh" do
        before do
          @def                          = FactoryGirl.build_stubbed(:content_view_definition)
          @view                         = FactoryGirl.build_stubbed(:content_view, :organization => @org)
          @view.content_view_definition = @def
          ContentView.stubs(:find).with(@view.id.to_s).returns(@view)
        end

        it "should call ContentView#refresh" do
          version = mock
          @view.expects(:refresh_view).returns(version)
          version.expects(:task_status).returns(TaskStatus.new)
          @def.expects(:publishable?).returns(true)
          post "refresh", :id => @view.id.to_s
          response.status.must_equal(202)
        end
      end

    end
  end
end
