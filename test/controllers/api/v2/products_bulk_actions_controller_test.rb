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
      FactoryBot.create(:katello_repository, :docker, :product_id => @products.first.id, :environment => @organization.library,
                         :content_view_version => @organization.default_content_view.versions.first, :url => 'http://foo.com/foo',
                         :docker_upstream_name => 'foobar', :unprotected => true, :mirroring_policy => 'additive')
    end

    def test_destroy_products
      test_product = @products.first
      assert_async_task ::Actions::Katello::Product::Destroy do |product|
        assert_equal test_product.id, product.id
      end

      put :destroy_products, params: { :ids => [test_product.id], :organization_id => @organization.id }

      assert_response :success
    end

    def test_destroy_products_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@update_permission, @create_permission, @sync_permission, @view_permission]

      assert_protected_action(:destroy_products, allowed_perms, denied_perms, [@organization]) do
        put :destroy_products, params: { :ids => @products.collect(&:cp_id), :organization_id => @organization.id }
      end
    end

    def test_sync
      expected_repo_size = Katello::Repository.in_default_view.
                            where(root: Katello::RootRepository.has_url.
                                        where(product: @products.syncable)).count

      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        action_class.must_equal ::Actions::Katello::Repository::Sync
        assert_equal expected_repo_size, repos.size
      end

      put :sync_products, params: { :ids => @products.collect(&:id), :organization_id => @organization.id }

      assert_response :success
    end

    def test_sync_with_skip_metadata_check
      create_docker_repo
      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        action_class.must_equal ::Actions::Katello::Repository::Sync
        refute_empty repos
        assert repos.all? { |repo| repo.yum? }
      end

      put :sync_products, params: { :ids => @products.collect(&:id), :organization_id => @organization.id, :skip_metadata_check => true }

      assert_response :success
    end

    def test_sync_with_validate_contents
      create_docker_repo
      FactoryBot.create(:katello_repository, :content_type => 'yum', :product_id => @products.first.id, :environment => @organization.library,
                         :content_view_version => @organization.default_content_view.versions.first, :download_policy => 'on_demand')

      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        action_class.must_equal ::Actions::Katello::Repository::Sync
        refute_empty repos
        assert repos.all? { |repo| repo.yum? } && repos.all? { |repo| repo.download_policy != ::Katello::RootRepository::DOWNLOAD_ON_DEMAND }
      end

      put :sync_products, params: { :ids => @products.collect(&:id), :organization_id => @organization.id, :validate_contents => true }

      assert_response :success
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@update_permission, @destroy_permission, @view_permission, @create_permission]

      assert_protected_action(:sync_products, allowed_perms, denied_perms, [@organization]) do
        put :sync_products, params: { :ids => @products.collect(&:id), :organization_id => @organization.id }
      end
    end

    def test_verify_checksum
      FactoryBot.create(:katello_repository, :content_type => 'yum',
                        :product_id => @products.first.id,
                        :environment => @organization.library,
                        :content_view_version => @organization.default_content_view.versions.first)

      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        refute_empty repos
        action_class.must_equal ::Actions::Katello::Repository::VerifyChecksum
      end

      put :verify_checksum_products, params: { :ids => @products.collect(&:id), :organization_id => @organization.id }
    end

    def test_verify_checksum_products_protected
      allowed_perms = [@update_permission]
      denied_perms = [@create_permission, @sync_permission, @view_permission, @destroy_permission]

      assert_protected_action(:verify_checksum_products, allowed_perms, denied_perms, [@organization]) do
        put :verify_checksum_products, params: { :ids => @products.collect(&:id), :organization_id => @organization.id }
      end
    end

    def test_update_http_proxy
      prod = @products.first
      assert_async_task(::Actions::Katello::Product::UpdateHttpProxy, [prod], 'global_default_http_proxy', nil)

      put :update_http_proxy, params: { :ids => [prod.id], :organization_id => @organization.id,
                                        :http_proxy_policy => 'global_default_http_proxy' }

      assert_response :success
    end

    def test_update_http_proxy_specific
      proxy = FactoryBot.create(:http_proxy)
      prod = @products.first
      assert_async_task(::Actions::Katello::Product::UpdateHttpProxy, [prod], 'use_selected_http_proxy', proxy)

      put :update_http_proxy, params: { :ids => [prod.id],
                                        :http_proxy_policy => 'use_selected_http_proxy',
                                        :http_proxy_id => proxy.id}

      assert_response :success
    end

    def test_update_http_proxy_protected
      allowed_perms = [@update_permission]
      denied_perms = [@sync_permission, @create_permission, @destroy_permission, @view_permission]

      assert_protected_action(:update_http_proxy, allowed_perms, denied_perms, [@organization]) do
        put :update_http_proxy, params: { :ids => @products.collect(&:id) }
      end
    end

    def test_update_sync_plans
      Product.any_instance.expects(:save!).times(@products.length).returns([{}])

      put :update_sync_plans, params: { :ids => @products.collect(&:id), :organization_id => @organization.id, :plan_id => 1 }

      assert_response :success
    end

    def test_update_sync_plans_protected
      allowed_perms = [@update_permission]
      denied_perms = [@sync_permission, @create_permission, @destroy_permission, @view_permission]

      assert_protected_action(:update_sync_plans, allowed_perms, denied_perms, [@organization]) do
        put :update_sync_plans, params: { :ids => @products.collect(&:id), :organization_id => @organization.id }
      end
    end
  end
end
