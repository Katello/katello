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

require 'spec_helper.rb'

describe Api::V1::DistributionsController, :katello => true do
  include LoginHelperMethods
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
    @repo.stub(:has_distribution?).and_return(true)
    Repository.stub(:find).and_return(@repo)
    @repo.stub(:distributions).and_return([])
    ::Distribution.stub(:find).and_return([])

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
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
        Repository.should_receive(:find).once.with(@repo.id.to_s).and_return(@repo)
        @repo.should_receive(:distributions)
        get 'index', :repository_id => @repo.id.to_s
      end
    end
  end
end

