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

require 'spec_helper'


describe RepositoriesController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include ProductHelperMethods
  include RepositoryHelperMethods
  include OrchestrationHelper
  include AuthorizationHelperMethods

  describe "rules" do
    before do
      disable_product_orchestration
      disable_user_orchestration

      @organization = new_test_org
      @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
      Provider.stub!(:find).and_return(@provider)
      @product = Product.new({:name=>"prod", :label=> "prod"})

      @product.provider = @provider
      @product.stub(:arch).and_return('noarch')
      @product.save!
      Product.stub!(:find).and_return(@product)
      @repository = MemoStruct.new(:id =>1222)
    end

    describe "GET New" do
      let(:action) {:new}
      let(:req) { get :new, :provider_id => @provider.id, :product_id => @product.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers,@provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "GET Edit" do
      before do
        Product.stub!(:find).and_return(@product)
        Katello.pulp_server.extensions.repository.stub(:find).and_return(@repository)
      end
      let(:action) {:edit}
      let(:req) { get :edit, :provider_id => @provider.id, :product_id => @product.id, :id => @repository.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers,@provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end

  describe "destroy a repository" do
     before(:each) do
       login_user

       Provider.stub(:find).and_return(mock_model(Repository))
       Product.stub(:find).and_return(@product = mock_model(Product))
       @product.stub(:editable?).and_return(true)

       @repository = mock_model(Repository, :name=>"deleted", :id => 123456).as_null_object
       Repository.stub(:find).and_return(@repository)
       @repository.stub(:destroy)
     end

     describe "on success" do
       before(:each) { @repository.stub(:destroyed?).and_return(true) }

       it "destroys the requested repository" do
         @repository.should_receive(:destroy)
         @repository.should_receive(:destroyed?)
         delete :destroy, :id => "123456", :provider_id => "123", :product_id => "123", :format => :js
       end

        it "updates the view" do
          delete :destroy, :id => "123456", :provider_id => "123", :product_id => "123", :format => :js
          response.should render_template(:partial => 'common/_post_delete_close_subpanel')
        end
     end

     describe "on failure" do
       before(:each) { @repository.stub(:destroyed?).and_return(false) }

       it "should produce an error notice on failure" do
         controller.should notify.error
         delete :destroy, :id => "123456", :provider_id => "123", :product_id => "123"
       end

       it "shouldn't render anything on failure" do
         delete :destroy, :id => "123456", :provider_id => "123", :product_id => "123"
         response.body.should be_blank
       end
     end
   end

  describe "other-tests" do
    before (:each) do
      login_user
      set_default_locale

      @org = new_test_org
      @product = new_test_product(@org, @org.library)
      @gpg = GpgKey.create!(:name => "foo", :organization => @organization, :content => "222")
      controller.stub!(:current_organization).and_return(@org)
      Resources::Candlepin::Content.stub(:create => {:id => "123"})
    end
    let(:invalidrepo) do
      {
        :product_id => @product.id,
        :provider_id => @product.provider.id,
        :repo => {
          :name => 'test',
          :feed => 'www.foo.com'
        }
      }
    end

    describe "Create a Repo" do
      it "should reject invalid urls" do
        controller.should notify.error
        post :create, invalidrepo
        response.should_not be_success
      end
    end

    context "Test gpg create" do
      before do
        disable_product_orchestration
        content = { :name => "FOO",
                    :id=>"12345",
                    :contentUrl => '/some/path',
                    :gpgUrl => nil,
                    :type => "yum",
                    :label => 'label',
                    :vendor => Provider::CUSTOM}

        Resources::Candlepin::Content.stub!(:get).and_return(content)
        Resources::Candlepin::Content.stub!(:create).and_return(content)
        Repository.any_instance.stub(:publish_yum_distributor)
        Katello.pulp_server.extensions.repository.stub(:publish_all).and_return([])
        @repo_name = "repo-#{rand 10 ** 8}"
        post :create, { :product_id => @product.id,
                        :provider_id => @product.provider.id,
                        :repo => {:name => @repo_name,
                              :label => @repo_name,
                              :feed => "http://foo.com",
                              :unprotected => false,
                              :content_type => "yum",
                              :gpg_key =>@gpg.id.to_s}}
      end
      specify  do
        response.should be_success
      end
      subject {Repository.find_by_name(@repo_name)}
      it{should_not be_nil}
      its(:gpg_key){should == @gpg}
      its(:unprotected){should == false}
    end

    context "Test update gpg" do
      before do
        disable_product_orchestration
        content = { :name => "FOO",
                    :id=>"12345",
                    :contentUrl => '/some/path',
                    :gpgUrl => nil,
                    :type => "yum",
                    :label => 'label',
                    :vendor => Provider::CUSTOM}

        Resources::Candlepin::Content.stub!(:get).and_return(content)
        Resources::Candlepin::Content.stub!(:create).and_return(content)

        @repo = new_test_repo(@organization.library, @product, "newname#{rand 10**6}", "http://fedorahosted org")
        product = @repo.product
        Repository.stub(:find).and_return(@repo)
        @repo.stub(:content).and_return(OpenStruct.new(:gpgUrl=>""))
        @repo.should_receive(:update_content).and_return(Candlepin::Content.new)
        #@repo.stub(:product).and_return(product)

        put :update_gpg_key, { :product_id => @product.id,
                              :provider_id => @product.provider.id,
                                :id => @repo.id,
                                :gpg_key => @gpg.id.to_s}
      end

      specify do
        response.should be_success
      end

      subject {Repository.find(@repo.id)}
      it{should_not be_nil}
      its(:gpg_key){should == @gpg}
    end
  end
end
