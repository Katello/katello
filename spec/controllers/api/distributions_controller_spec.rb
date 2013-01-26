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

describe Api::DistributionsController, :katello => true do
  include LoginHelperMethods
  include AuthorizationHelperMethods

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
    @product = Product.create!(:name=>"prod", :label=> "prod",
                               :provider => @provider,
                               :environments => [@organization.library])
    @product.stub(:repos).and_return([@repository])

    ep_library = EnvironmentProduct.find_or_create(@organization.library, @product)
    @repo = Repository.create!(:environment_product => ep_library,
                               :name=> "repo",
                               :label=> "repo_label",
                               :relative_path => "#{@organization.name}/Library/prod/repo",
                               :pulp_id=> "1",
                               :enabled => true,
                               :feed => 'https://localhost')
    @repo.stub(:has_distribution?).and_return(true)
    Repository.stub(:find).and_return(@repo)
    @repo.stub(:distributions).and_return([])
    Glue::Pulp::Distribution.stub(:find).and_return([])

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
        Repository.should_receive(:find).once.with(@repo.id).and_return(@repo)
        @repo.should_receive(:distributions)
        get 'index', :repository_id => @repo.id
      end
    end
  end
end

