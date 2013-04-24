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

describe Api::ErrataController, :katello => true do
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
    @env = @organization.library
    @product = new_test_product(@organization, @env)
    ep_library = EnvironmentProduct.find_or_create(@organization.library, @product)
    @repo = new_test_repo(ep_library, "repo", "#{@organization.name}/Library/prod/repo")

    @product.stub(:repos).and_return([@repository])
    @repo.stub(:has_distribution?).and_return(true)
    Repository.stub(:find).and_return(@repo)

    KTEnvironment.stub(:find).and_return(@organization.library)
    @erratum = {}
    @erratum.stub(:repoids).and_return([ @repo.pulp_id ])
    ::Errata.stub(:find_by_errata_id => @erratum)
    ::Errata.stub(:filter => @erratum)

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
        get 'index', :repoid => @repo.id, :type => 'security'
      }
      it_should_behave_like "protected action"
    end

    describe "get a listing by env" do
      let(:action) { :index }
      let(:req) {
        get 'index', :type => 'security', :environment_id => "123"
      }
      it_should_behave_like "protected action"
    end

    describe "show" do
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

    describe "get a listing of erratas" do
      before(:each) do
        @repo = mock(Glue::Pulp::Repo)
      end

      it "should call pulp find repo api" do
        ::Errata.should_receive(:filter).once.with(:repoid => '1').and_return([])
        get 'index', :repoid => '1'
      end

      it "should accept type as filter attribute" do
        ::Errata.should_receive(:filter).once.with(:repoid => '1', :type => 'security').and_return([])
        get 'index', :repoid => '1', :type => 'security'

        ::Errata.should_receive(:filter).once.with(:type => 'security', :environment_id => '123').and_return([])
        get 'index', :type => 'security', :environment_id => "123"

        ::Errata.should_receive(:filter).once.with(:severity => 'critical', :environment_id => '123').and_return([])
        get 'index', :severity => 'critical', :environment_id => "123"

        ::Errata.should_receive(:filter).once.with(:severity => 'critical', :product_id => 'product-123', :environment_id => '123').and_return([])
        get 'index', :severity => 'critical', :product_id => 'product-123', :environment_id => "123"
      end

      it "should not accept a call without specifying envirovnemnt or repoid" do
        get 'index', :type => 'security'
        response.response_code.should == 400
      end
    end

    describe "show an erratum" do
      it "should call pulp find errata api" do
        ::Errata.should_receive(:find_by_errata_id).once.with('1')
        get 'show', :id => '1', :repository_id => 1
      end
    end
  end

end

