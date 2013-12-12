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
  describe RepositoriesController do

    include LocaleHelperMethods
    include OrganizationHelperMethods
    include ProductHelperMethods
    include RepositoryHelperMethods
    include OrchestrationHelper
    include AuthorizationHelperMethods

    describe "(katello)" do

      describe "rules" do
        before do
          setup_controller_defaults
          disable_product_orchestration
          disable_user_orchestration

          @organization = new_test_org
          @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
          Provider.stubs(:find).returns(@provider)
          @product = Product.new({:name=>"prod", :label=> "prod"})

          @product.provider = @provider
          @product.stubs(:arch).returns('noarch')
          @product.save!
          Product.stubs(:find).returns(@product)
          @repository = OpenStruct.new(:id =>1222)
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
            Product.stubs(:find).returns(@product)
            Katello.pulp_server.extensions.repository.stubs(:find).returns(@repository)
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
          setup_controller_defaults

          @organization = get_organization(:organization1)
          @controller.stubs(:current_organization).returns(@organization)

          Provider.stubs(:find).returns(stub(:id => 1))
          Product.stubs(:find).returns(@product = stub)
          @product.stubs(:editable?).returns(true)

          @repository = OpenStruct.new(:name=>"deleted", :id => 123456)
          Repository.stubs(:find).returns(@repository)
          @repository.stubs(:destroy)
        end

        describe "on success" do
          before(:each) { @repository.stubs(:destroyed?).returns(true) }

          it "destroys the requested repository" do
            @repository.expects(:destroy)
            @repository.expects(:destroyed?)
            delete :destroy, :id => "123456", :provider_id => "123", :product_id => "123", :format => :js
          end

          it "updates the view" do
            delete :destroy, :id => "123456", :provider_id => "123", :product_id => "123", :format => :js
            must_render_template(:partial => 'katello/common/_post_delete_close_subpanel')
          end
        end

        describe "on failure" do
          before(:each) { @repository.stubs(:destroyed?).returns(false) }

          it "should produce an error notice on failure" do
            must_notify_with(:error)
            delete :destroy, :id => "123456", :provider_id => "123", :product_id => "123"
          end

          it "shouldn't render anything on failure" do
            delete :destroy, :id => "123456", :provider_id => "123", :product_id => "123"
            response.body.must_be :blank?
          end
        end
      end

      describe "other-tests" do
        before (:each) do
          setup_controller_defaults
          set_default_locale

          @org = new_test_org
          @product = new_test_product(@org, @org.library)
          test_gpg_content = File.open("#{Katello::Engine.root}/spec/assets/gpg_test_key").read
          @gpg = GpgKey.create!(:name => "foo", :organization => @organization, :content => test_gpg_content)
          @controller.stubs(:current_organization).returns(@org)
          Resources::Candlepin::Content.stubs(:create => {:id => "123"})
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
            must_notify_with(:error)
            post :create, invalidrepo
            response.must_respond_with(400)
          end
        end

        context "Test gpg create" do
          before do
            disable_product_orchestration
            Repository.any_instance.stubs(:create_pulp_repo).returns({})
            Repository.any_instance.stubs(:setup_sync_schedule).returns({})
            Repository.any_instance.stubs(:set_sync_schedule).returns({})
            content = { :name => "FOO",
                        :id=>"12345",
                        :contentUrl => '/some/path',
                        :gpgUrl => nil,
                        :type => "yum",
                        :label => 'label',
                        :vendor => Provider::CUSTOM}

            Resources::Candlepin::Content.stubs(:get).returns(content)
            Resources::Candlepin::Content.stubs(:create).returns(content)
            Repository.any_instance.stubs(:generate_metadata)
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
            must_respond_with(:success)
          end
          subject {Repository.find_by_name(@repo_name)}
          it{wont_be_nil}
          it {subject.gpg_key.must_equal @gpg}
          it {subject.unprotected.must_equal false}
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

            Resources::Candlepin::Content.stubs(:get).returns(content)
            Resources::Candlepin::Content.stubs(:create).returns(content)

            @repo = new_test_repo(@organization.library, @product, "newname#{rand 10**6}", "http://fedorahosted org")
            product = @repo.product
            Repository.stubs(:find).returns(@repo)
            @repo.stubs(:content).returns(OpenStruct.new(:gpgUrl=>""))
            @repo.expects(:update_content).returns(Candlepin::Content.new)
            #@repo.stubs(:product).returns(product)

            put :update_gpg_key, { :product_id => @product.id,
                                   :provider_id => @product.provider.id,
                                   :id => @repo.id,
                                   :gpg_key => @gpg.id.to_s}
          end

          specify do
            must_respond_with(:success)
          end

          subject {Repository.find(@repo.id)}
          it{wont_be_nil}
          it {subject.gpg_key.must_equal @gpg}
        end
      end
    end
  end
end
