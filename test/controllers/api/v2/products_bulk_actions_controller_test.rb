require "katello_test_helper"

module Katello
  class Api::V2::ProductsBulkActionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @products = Product.where(:id => katello_products(:empty_product, :fedora).map(&:id))
      @provider = katello_providers(:fedora_hosted)
    end

    def permissions
      @view_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      User.current = User.find(users(:admin).id)
      models
      permissions
    end

    def create_docker_repo
      FactoryGirl.create(:katello_repository, :docker, :product_id => @products.first.id, :environment => @organization.library,
                         :content_view_version => @organization.default_content_view.versions.first, :url => 'http://foo.com/foo',
                         :docker_upstream_name => 'foobar', :unprotected => true)
    end

    def test_destroy_products
      test_product = @products.first
      assert_async_task ::Actions::Katello::Product::Destroy do |product|
        test_product.id.must_equal product.id
      end

      put :destroy_products, :ids => [test_product.id], :organization_id => @organization.id

      assert_response :success
    end

    def test_destroy_products_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@update_permission, @create_permission, @sync_permission, @view_permission]

      assert_protected_action(:destroy_products, allowed_perms, denied_perms, [@organization]) do
        put :destroy_products, :ids => @products.collect(&:cp_id), :organization_id => @organization.id
      end
    end

    def test_sync
      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        action_class.must_equal ::Actions::Katello::Repository::Sync
        repos.size.must_equal 9
      end

      put :sync_products, :ids => @products.collect(&:id), :organization_id => @organization.id

      assert_response :success
    end

    def test_sync_with_skip_metadata_check
      create_docker_repo
      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        action_class.must_equal ::Actions::Katello::Repository::Sync
        refute repos.empty?
        assert repos.all? { |repo| repo.yum? }
      end

      put :sync_products, :ids => @products.collect(&:id), :organization_id => @organization.id, :skip_metadata_check => true

      assert_response :success
    end

    def test_sync_with_validate_contents
      create_docker_repo
      FactoryGirl.create(:katello_repository, :content_type => 'yum', :product_id => @products.first.id, :environment => @organization.library,
                         :content_view_version => @organization.default_content_view.versions.first, :download_policy => 'on_demand')

      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        action_class.must_equal ::Actions::Katello::Repository::Sync
        refute repos.empty?
        assert repos.all? { |repo| repo.yum? } && repos.all? { |repo| repo.download_policy != ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND }
      end

      put :sync_products, :ids => @products.collect(&:id), :organization_id => @organization.id, :validate_contents => true

      assert_response :success
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@update_permission, @destroy_permission, @view_permission, @create_permission]

      assert_protected_action(:sync_products, allowed_perms, denied_perms, [@organization]) do
        put :sync_products, :ids => @products.collect(&:id), :organization_id => @organization.id
      end
    end

    def test_update_sync_plans
      Product.any_instance.expects(:save!).times(@products.length).returns([{}])

      put :update_sync_plans, :ids => @products.collect(&:id), :organization_id => @organization.id, :plan_id => 1

      assert_response :success
    end

    def test_update_sync_plans_protected
      allowed_perms = [@update_permission]
      denied_perms = [@sync_permission, @create_permission, @destroy_permission, @view_permission]

      assert_protected_action(:update_sync_plans, allowed_perms, denied_perms, [@organization]) do
        put :update_sync_plans, :ids => @products.collect(&:id), :organization_id => @organization.id
      end
    end
  end
end
