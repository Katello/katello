require 'katello_test_helper'

module Katello
  class Api::V2::AlternateContentSourcesControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @acs = katello_alternate_content_sources(:yum_alternate_content_source)
      @ca = katello_gpg_keys(:fedora_ca)
      @cert = katello_gpg_keys(:fedora_cert)
      @key = katello_gpg_keys(:fedora_key)
      @http_proxy = FactoryBot.create(:http_proxy)
      @smart_proxy = ::SmartProxy.pulp_primary

      @ca.save!
      @cert.save!
      @key.save!
      @http_proxy.save!
      @acs.ssl_ca_cert = @ca
      @acs.ssl_client_cert = @cert
      @acs.ssl_client_key = @key
      @acs.http_proxy = @http_proxy
      @acs.subpaths = ['content/', 'isos/', 'packages/']
      @acs.save!
    end

    def permissions
      @read_permission = :view_alternate_content_sources
      @create_permission = :create_alternate_content_sources
      @update_permission = :edit_alternate_content_sources
      @destroy_permission = :destroy_alternate_content_sources
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_index
      get :index

      assert_response :success
      assert_template 'api/v2/alternate_content_sources/index'
    end

    def test_show
      get :show, params: { :id => @acs.id }

      assert_response :success
      assert_template 'api/v2/alternate_content_sources/show'
    end

    def test_create
      ::Katello::AlternateContentSource.any_instance.stubs(:reload).returns(@acs)

      assert_sync_task(::Actions::Katello::AlternateContentSource::Create) do |acs, smart_proxies|
        assert_equal acs.attributes.except('id', 'label'), @acs.attributes.except('id', 'label')
        assert_equal [@smart_proxy.id], smart_proxies.pluck(:id)
      end

      post :create, params: {
        name: @acs.name,
        smart_proxy_ids: [@smart_proxy.id],
        http_proxy_id: @http_proxy.id,
        ssl_ca_cert_id: @ca.id,
        ssl_client_cert_id: @cert.id,
        ssl_client_key_id: @key.id,
        content_type: @acs.content_type,
        base_url: @acs.base_url,
        subpaths: @acs.subpaths,
        alternate_content_source_type: @acs.alternate_content_source_type,
        verify_ssl: @acs.verify_ssl,
        upstream_username: @acs.upstream_username,
        upstream_password: @acs.upstream_password
      }
      assert_response :success
      assert_template 'api/v2/common/create'
    end

    def test_create_bad_base_url
      @acs.base_url = 'not a path'
      ::Katello::AlternateContentSource.any_instance.stubs(:reload).returns(@acs)

      post :create, params: {
        name: @acs.name,
        smart_proxy_ids: [@smart_proxy.id],
        http_proxy_id: @http_proxy.id,
        ssl_ca_cert_id: @ca.id,
        ssl_client_cert_id: @cert.id,
        ssl_client_key_id: @key.id,
        content_type: @acs.content_type,
        base_url: @acs.base_url,
        subpaths: @acs.subpaths,
        alternate_content_source_type: @acs.alternate_content_source_type,
        verify_ssl: @acs.verify_ssl,
        upstream_username: @acs.upstream_username,
        upstream_password: @acs.upstream_password
      }
      assert_response :unprocessable_entity
    end

    def test_create_bad_subpaths
      @acs.subpaths = ['not a path', '/not a path']
      ::Katello::AlternateContentSource.any_instance.stubs(:reload).returns(@acs)

      post :create, params: {
        name: @acs.name,
        smart_proxy_ids: [@smart_proxy.id],
        http_proxy_id: @http_proxy.id,
        ssl_ca_cert_id: @ca.id,
        ssl_client_cert_id: @cert.id,
        ssl_client_key_id: @key.id,
        content_type: @acs.content_type,
        base_url: @acs.base_url,
        subpaths: @acs.subpaths,
        alternate_content_source_type: @acs.alternate_content_source_type,
        verify_ssl: @acs.verify_ssl,
        upstream_username: @acs.upstream_username,
        upstream_password: @acs.upstream_password
      }
      assert_response :unprocessable_entity
    end

    def test_update
      assert_sync_task(::Actions::Katello::AlternateContentSource::Update) do |acs, smart_proxies|
        assert_equal acs.attributes.except('id', 'label'), @acs.attributes.except('id', 'label')
        assert_equal [@smart_proxy.id], smart_proxies.pluck(:id)
      end

      put :update, params: {
        id: @acs.id,
        name: @acs.name,
        smart_proxy_ids: [@smart_proxy.id],
        http_proxy_id: @http_proxy.id,
        ssl_ca_cert_id: @ca.id,
        ssl_client_cert_id: @cert.id,
        ssl_client_key_id: @key.id,
        content_type: @acs.content_type,
        base_url: @acs.base_url,
        subpaths: @acs.subpaths,
        alternate_content_source_type: @acs.alternate_content_source_type,
        verify_ssl: @acs.verify_ssl,
        upstream_username: @acs.upstream_username,
        upstream_password: @acs.upstream_password
      }
      assert_response :success
      assert_template 'api/v2/alternate_content_sources/show'
    end

    def test_update_bad_base_url
      @acs.base_url = 'not a path'

      put :update, params: {
        id: @acs.id,
        name: @acs.name,
        smart_proxy_ids: [@smart_proxy.id],
        http_proxy_id: @http_proxy.id,
        ssl_ca_cert_id: @ca.id,
        ssl_client_cert_id: @cert.id,
        ssl_client_key_id: @key.id,
        content_type: @acs.content_type,
        base_url: @acs.base_url,
        subpaths: @acs.subpaths,
        alternate_content_source_type: @acs.alternate_content_source_type,
        verify_ssl: @acs.verify_ssl,
        upstream_username: @acs.upstream_username,
        upstream_password: @acs.upstream_password
      }
      assert_response :unprocessable_entity
    end

    def test_update_bad_subpaths
      @acs.subpaths = ['not a path', '/not a path']

      put :update, params: {
        id: @acs.id,
        name: @acs.name,
        smart_proxy_ids: [@smart_proxy.id],
        http_proxy_id: @http_proxy.id,
        ssl_ca_cert_id: @ca.id,
        ssl_client_cert_id: @cert.id,
        ssl_client_key_id: @key.id,
        content_type: @acs.content_type,
        base_url: @acs.base_url,
        subpaths: @acs.subpaths,
        alternate_content_source_type: @acs.alternate_content_source_type,
        verify_ssl: @acs.verify_ssl,
        upstream_username: @acs.upstream_username,
        upstream_password: @acs.upstream_password
      }
      assert_response :unprocessable_entity
    end

    def test_destroy
      assert_sync_task(::Actions::Katello::AlternateContentSource::Destroy) do |acs|
        assert_equal acs.attributes.except('id', 'label'), @acs.attributes.except('id', 'label')
      end

      delete :destroy, params: { :id => @acs.id }

      assert_response :success
    end
  end
end
