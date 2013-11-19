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
describe Api::V1::DistributionsController do
  describe "(katello)" do
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include ProductHelperMethods
  include RepositoryHelperMethods
  include LocaleHelperMethods

  before(:each) do
    disable_org_orchestration
    disable_product_orchestration
    disable_user_orchestration
    disable_repo_orchestration

    @organization = new_test_org
    @env          = @organization.library
    @product      = new_test_product(@organization, @env)
    @repo         = new_test_repo(@env, @product, "repo", "#{@organization.name}/Library/prod/repo")
    @repo.stubs(:has_distribution?).returns(true)
    Repository.stubs(:find).returns(@repo)
    @repo.stubs(:distributions).returns([])
    Katello::Distribution.stubs(:find).returns([])

    @request.env["HTTP_ACCEPT"] = "application/json"
    setup_controller_defaults_api
  end
  let(:authorized_user) do
    user_with_permissions do |u|
      u.can(:read_contents, :environments, @organization.library.id, @organization)
      u.can(:read, :providers, @provider.id, @organization)
    end
  end
  let(:unauthorized_user) do
    user_without_permissions
  end

  context "rules" do
    describe "get a listing of distributions" do
      let(:action) { :index }
      let(:req) {
        get 'index', :repository_id => @repo.id
      }
      it_should_behave_like "protected action"
    end

    describe "show a distribution" do
      let(:action) { :show }
      let(:req) {
        get 'show', :id => 1, :repository_id => @repo.id
      }
      it_should_behave_like "protected action"
    end
  end

  context "test" do
    before do
      disable_authorization_rules
    end

    describe "get a listing of distributions" do
      it "should call pulp find repo api" do
        Repository.expects(:find).once.with(@repo.id.to_s).returns(@repo)
        @repo.expects(:distributions)
        get 'index', :repository_id => @repo.id.to_s
      end
    end
  end
end
end
end