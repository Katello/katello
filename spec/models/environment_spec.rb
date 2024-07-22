require 'katello_test_helper'

module Katello
  describe KTEnvironment do
    include OrchestrationHelper
    include OrganizationHelperMethods

    describe "main" do
      before(:each) do
        disable_org_orchestration

        Repository.any_instance.stubs(:save_content_orchestration).returns(true)
        Repository.any_instance.stubs(:clear_content_indices).returns(true)
        Repository.any_instance.stubs(:destroy_repo_orchestration).returns(true)

        @env_name = 'test_environment'
        @organization = get_organization
        @provider = @organization.redhat_provider

        @first_product = Product.create!(:name => "prod1", :label => "prod1", :cp_id => '12345', :provider => @provider, :organization => @organization)
        @second_product = Product.create!(:name => "prod2", :label => "prod2", :cp_id => '67890', :provider => @provider, :organization => @organization)
        @third_product = Product.create!(:name => "prod3", :label => "prrod3", :cp_id => '45678', :provider => @provider, :organization => @organization)
        @fourth_product = Product.create!(:name => "prod4", :label => "prod4", :cp_id => '32683', :provider => @provider, :organization => @organization)
        @environment = create_environment(:name => @env_name, :organization => @organization, :label => @env_name, :prior => @organization.library)
        @organization.reload
        FactoryBot.create(:katello_repository, product: @first_product, environment: @environment,
                                                content_view_version_id: @environment.content_view_versions.first.id)
        FactoryBot.create(:katello_repository, product: @third_product, environment: @environment,
                                                content_view_version_id: @environment.content_view_versions.first.id)
      end

      specify { value(@environment.prior).wont_be :nil? }
      specify { value(@environment.successor).must_be :nil? }
      specify { value(@organization.kt_environments).must_include(@environment) }
      specify { value(@environment.organization).must_equal(@organization) }
      specify { value(@environment.products.size).must_equal(2) }
      specify { value(@environment.products).must_include(@first_product) }
      specify { value(@environment.products).must_include(@third_product) }

      describe "prior environment can be set" do
        before do
          @new_env = KTEnvironment.create!(
                                             :name => @environment.name + '-prior',
                                             :label => @environment.name + '-prior',
                                             :prior => @environment.id,
                                             :organization => @organization
          )
        end

        specify { value(@new_env.prior).must_equal(@environment) }
        specify { value(@environment.successor).must_equal(@new_env) }
      end

      describe "update an environment" do
        specify "name should not be changed" do
          @environment.name = "changed_name"
          value(@environment).must_be :valid?
        end
      end

      describe "delete an environment" do
        it "should delete the environment" do
          env = KTEnvironment.create!(:name => "Boooo1224",
                                      :organization => @organization,
                                      :prior => @organization.library)
          id = env.id
          env.destroy!
          lambda { KTEnvironment.find(id) }.must_raise(ActiveRecord::RecordNotFound) # rubocop:disable Minitest/GlobalExpectations
        end
      end

      describe "available products" do
        before(:each) do
          @prior_env = create_environment(:name => @environment.name + '-prior', :label => @environment.name + '-prior',
                                          :prior => @environment.id, :organization => @organization)

          FactoryBot.create(:katello_repository, environment: @prior_env, product: @first_product,
                                                  content_view_version_id: @prior_env.content_view_versions.first.id)
          FactoryBot.create(:katello_repository, environment: @prior_env, product: @second_product,
                                                  content_view_version_id: @prior_env.content_view_versions.first.id)
          FactoryBot.create(:katello_repository, environment: @prior_env, product: @third_product,
                                                  content_view_version_id: @prior_env.content_view_versions.first.id)

          FactoryBot.create(:katello_repository, environment: @organization.library, product: @first_product,
                                                  content_view_version_id: @organization.library.content_view_versions.first.id)
          FactoryBot.create(:katello_repository, environment: @organization.library, product: @second_product,
                                                  content_view_version_id: @organization.library.content_view_versions.first.id)
          FactoryBot.create(:katello_repository, environment: @organization.library, product: @third_product,
                                                  content_view_version_id: @organization.library.content_view_versions.first.id)
          FactoryBot.create(:katello_repository, environment: @organization.library, product: @fourth_product,
                                                  content_view_version_id: @organization.library.content_view_versions.first.id)
        end

        it "should return products from prior env" do
          @environment.prior = @prior_env.id
          product_size = @prior_env.products.size - @environment.products.size
          value(@environment.available_products.size).must_equal(product_size)
          value(@environment.available_products).must_include(@second_product)
        end

        it "should return products from the library if there is no prior env" do
          product_size = @organization.library.products.size - @environment.products.size
          value(@environment.available_products.size).must_equal(product_size)
          value(@environment.available_products).must_include(@second_product)
          value(@environment.available_products).must_include(@fourth_product)
        end
      end

      describe "create environment with invalid parameters" do
        it "should be invalid to create two envs with the same name within one organization" do
          @environment2 = KTEnvironment.new(:name => @env_name)
          @organization.kt_environments << @environment2

          value(@environment2).wont_be :valid?
          value(@environment2.errors[:name]).wont_be :empty?
        end

        it "should be valid to create an environment without a prior" do
          @environment2 = KTEnvironment.new(:name => "random env")
          @organization.kt_environments << @environment2

          value(@environment2).must_be :valid?
          value(@environment2.errors[:prior]).must_be :empty?
        end
      end

      describe "environment path" do
        before(:each) do
          @env1 = create_environment(:name => @env_name + '-succ1',
                                     :label => 'env-succ1',
                                     :organization => @organization,
                                     :prior => @environment)
        end

        specify { value(@environment.path.size).must_equal(2) }
        specify { value(@environment.path).must_include(@env1) }
        specify { value(@environment.path).must_include(@environment) }
      end

      describe "libraries" do
        it "should be the only KTEnvironment that can have multiple priors" do
          @env1 = KTEnvironment.new(:name => @env_name + '1', :label => @env_name + '1',
                                    :organization => @organization, :prior => @organization.library)
          @env2 = KTEnvironment.new(:name => @env_name + '2', :label => @env_name + '2',
                                    :organization => @organization, :prior => @organization.library)
          @env3 = KTEnvironment.new(:name => @env_name + '3', :label => @env_name + '3',
                                    :organization => @organization, :prior => @organization.library)

          value(@env1).must_be :valid?
          value(@env2).must_be :valid?
          value(@env3).must_be :valid?
          value(@organization.library).must_be :valid?
        end
      end
    end
  end
end
