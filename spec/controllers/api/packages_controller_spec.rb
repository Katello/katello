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

require 'spec_helper.rb'

describe Api::PackagesController, :katello => true do
  include LoginHelperMethods
  include AuthorizationHelperMethods

  let(:repo_id) {'f8ab5088-688e-4ce4-ade3-700aa4cbb070'}
  before(:each) do
    disable_org_orchestration
    disable_product_orchestration
    disable_user_orchestration
    disable_repo_orchestration

    @organization = new_test_org
    @provider = Provider.create!(:name => "provider",
                                 :provider_type => Provider::CUSTOM,
                                 :organization => @organization,
                                 :repository_url => "https://localhost")
    @product = Product.create!(:name => "prod",
                               :provider => @provider,
                               :environments => [@organization.library])
    @product.stub(:repos).and_return([@repository])

    ep_library = EnvironmentProduct.find_or_create(@organization.library, @product)
    @repo = Repository.create!(:environment_product => ep_library,
                               :name=> "repo",
                               :relative_path => "#{@organization.name}/Library/prod/repo",
                               :pulp_id=> "1",
                               :enabled => true)
    @repo.stub(:has_distribution?).and_return(true)
    @repo.stub(:pulp_id).and_return(repo_id)
    Repository.stub(:find).and_return(@repo)
    @repo.stub(:distributions).and_return([])
    Glue::Pulp::Distribution.stub(:find).and_return([])

    @repo.stub(:packages).and_return([])
    package = { 'repoids' => [ repo_id ] }
    Pulp::Package.stub(:find).and_return(package)

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
    describe "get a listing by repo" do
      let(:action) { :index }
      let(:req) {
        get 'index', :repository_id => repo_id
      }
      it_should_behave_like "protected action"
    end

    describe "show" do
      let(:action) { :show }
      let(:req) {
        get 'show', :id => 1, :repository_id => repo_id
      }
      it_should_behave_like "protected action"
    end

    describe "search" do
      let(:action) { :search }
      let(:req) {
        get 'search', :id => 1, :repository_id => repo_id, :query => "cheetah*"
      }
      it_should_behave_like "protected action"
    end
  end

  context "tests" do
    before do
      disable_authorization_rules
    end
    describe "get a listing of packages" do
      it "should call pulp find packages api" do
        Repository.should_receive(:find).with(repo_id)
        get 'index', :repository_id => repo_id
      end
    end

    describe "show a package" do
      it "should call pulp find package api" do
        Pulp::Package.should_receive(:find).once.with(1)
        get 'show', :id => 1, :repository_id => repo_id
      end
    end

    describe "search for a package" do
      it "should call glue layer" do
        Glue::Pulp::Package.should_receive(:search).once.with("cheetah*", 0, 0, [@repo.pulp_id])
        get 'search', :repository_id => repo_id, :search => "cheetah*"
      end
    end
  end
end
