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

describe Api::ContentViewsController, :katello => true do
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
      @content_views = FactoryGirl.build_list(:content_view, 1)
      @organization.content_views = @content_views
    end

    let(:req) { get 'index', :organization_id => @organization.name }
    let(:org_view_ids) { @organization.content_views.map(&:id) }

    subject { req }
    it { should be_success }

    specify { subject and assigns[:content_views].map(&:id).should
      eql(org_view_ids) }
  end

end