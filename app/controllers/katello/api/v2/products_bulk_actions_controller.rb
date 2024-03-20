module Katello
  class Api::V2::ProductsBulkActionsController < Api::V2::ApiController
    before_action :find_products
    before_action :find_optional_proxy, :only => :update_http_proxy

    api :PUT, "/products/bulk/destroy", N_("Destroy one or more products")
    param :ids, Array, :desc => N_("List of product ids"), :required => true
    def destroy_products
      deletable_products = @products.deletable
      deletable_products.each do |prod|
        async_task(::Actions::Katello::Product::Destroy, prod)
      end

      messages = format_bulk_action_messages(
        :success    => _("Successfully initiated removal of %s product(s)"),
        :error      => _("You were not allowed to delete %s"),
        :models     => @products,
        :authorized => deletable_products
      )

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => messages }
    end

    api :PUT, "/products/bulk/sync", N_("Sync one or more products")
    param :ids, Array, :desc => N_("List of product ids"), :required => true
    param :skip_metadata_check, :bool, :desc => N_("Force sync even if no upstream changes are detected. Non-yum repositories are skipped."), :required => false
    param :validate_contents, :bool, :desc => N_("Force a sync and validate the checksums of all content. Non-yum repositories (or those with \
                                                     On Demand download policy) are skipped."), :required => false
    def sync_products
      skip_metadata_check = ::Foreman::Cast.to_bool(params[:skip_metadata_check])
      validate_contents = ::Foreman::Cast.to_bool(params[:validate_contents])

      syncable_products = @products.syncable
      syncable_roots = RootRepository.where(:product_id => syncable_products).has_url

      syncable_roots = syncable_roots.skipable_metadata_check if skip_metadata_check || validate_contents
      syncable_roots = syncable_roots.where.not(:download_policy => ::Katello::RootRepository::DOWNLOAD_ON_DEMAND) if validate_contents

      syncable_repositories = Katello::Repository.where(:root_id => syncable_roots).in_default_view
      fail _("No syncable repositories found for selected products and options.") if syncable_roots.empty?

      task = async_task(::Actions::BulkAction,
                        ::Actions::Katello::Repository::Sync,
                        syncable_repositories,
                        :skip_metadata_check => skip_metadata_check,
                        :validate_contents => validate_contents)

      respond_for_async :resource => task
    end

    api :PUT, "/products/bulk/verify_checksum", N_("Verify checksum for one or more products")
    param :ids, Array, :desc => N_("List of product ids"), :required => true
    def verify_checksum_products
      repairable_products = @products.syncable
      repairable_roots = RootRepository.where(:product_id => repairable_products).has_url.select { |r| r.library_instance }.uniq

      repairable_repositories = Katello::Repository.library.where(:root_id => repairable_roots)
      task = async_task(::Actions::BulkAction,
                        ::Actions::Katello::Repository::VerifyChecksum,
                        repairable_repositories)

      respond_for_async :resource => task
    end

    api :PUT, "/products/bulk/http_proxy", N_("Update the HTTP proxy configuration on the repositories of one or more products.")
    param :ids, Array, :desc => N_("List of product ids"), :required => true
    param :http_proxy_policy, ::Katello::RootRepository::HTTP_PROXY_POLICIES, :desc => N_("policy for HTTP proxy for content sync")
    param :http_proxy_id, :number, :desc => N_("HTTP Proxy identifier to associated"), :required => false
    def update_http_proxy
      task = async_task(::Actions::Katello::Product::UpdateHttpProxy,
                        @products.editable,
                        params[:http_proxy_policy],
                        @http_proxy)

      respond_for_async :resource => task
    end

    api :PUT, "/products/bulk/sync_plan", N_("Sync one or more products")
    param :ids, Array, :desc => N_("List of product ids"), :required => true
    param :plan_id, :number, :desc => N_("Sync plan identifier to attach"), :required => true
    def update_sync_plans
      editable_products = @products.editable
      editable_products.each do |product|
        product.sync_plan_id = params[:plan_id]
        product.save!
      end

      messages = format_bulk_action_messages(
        :success    => _("Successfully changed sync plan for %s product(s)"),
        :error      => _("You were not allowed to change sync plan for %s"),
        :models     => @products,
        :authorized => editable_products
      )

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => messages }
    end

    private

    def find_optional_proxy
      @http_proxy = ::HttpProxy.find(params[:http_proxy_id]) if params[:http_proxy_id]
    end

    def find_products
      params.require(:ids)
      @products = Product.readable.where(:id => params[:ids])
    end
  end
end
