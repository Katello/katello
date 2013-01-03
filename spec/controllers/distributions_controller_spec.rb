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
require 'helpers/repo_test_data'

describe DistributionsController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods

  let(:distribution_id) { RepoTestData.repo_distributions["id"] }
  let(:distribution) { [RepoTestData.repo_distributions] }

  before (:each) do
    login_user
    set_default_locale

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
                               :label => "repo_label",
                               :relative_path => "#{@organization.name}/Library/prod/repo",
                               :pulp_id=> "1",
                               :enabled => true,
                               :feed => 'https://localhost')
    Repository.stub(:find).and_return(@repo)
    Glue::Pulp::Distribution.stub(:find).and_return([])
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

  describe "GET show" do
    let(:action) {:show}
    let(:req) { get :show, :repository_id => @repo.id, :id => distribution_id }

    it_should_behave_like "protected action"

    it "should lookup the distribution" do
      Glue::Pulp::Distribution.should_receive(:find).once.with(distribution_id).and_return(distribution)
      req
    end

    it "renders show partial" do
      Glue::Pulp::Distribution.should_receive(:find).once.with(distribution_id).and_return(distribution)
      req
      response.should render_template(:partial => "_show")
    end

    it "should be successful" do
      Glue::Pulp::Distribution.should_receive(:find).once.with(distribution_id).and_return(distribution)
      req
      response.should be_success
    end
  end

  describe "GET filelist" do
    let(:action) {:filelist}
    let(:req) { get :filelist, :repository_id => @repo.id, :id => distribution_id }

    it_should_behave_like "protected action"

    it "should lookup the distribution" do
      Glue::Pulp::Distribution.should_receive(:find).once.with(distribution_id).and_return(distribution)
      req
    end

    it "renders the file list partial" do
      Glue::Pulp::Distribution.should_receive(:find).once.with(distribution_id).and_return(distribution)
      req
      response.should render_template(:partial => "_filelist")
    end

    it "should be successful" do
      Glue::Pulp::Distribution.should_receive(:find).once.with(distribution_id).and_return(distribution)
      req
      response.should be_success
    end
  end

end
