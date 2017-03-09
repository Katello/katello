module Katello
  class Api::V2::ProductsBulkActionsController < Api::V2::ApiController
    before_action :find_products

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
      syncable_repositories = Repository.where(:product_id => syncable_products).has_url

      syncable_repositories = syncable_repositories.where(:content_type => Repository::YUM_TYPE) if skip_metadata_check || validate_contents
      syncable_repositories = syncable_repositories.where.not(:download_policy => ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND) if validate_contents

      fail _("No syncable repositories found for selected products and options.") if syncable_repositories.empty?

      task = async_task(::Actions::BulkAction,
                        ::Actions::Katello::Repository::Sync,
                        syncable_repositories,
                        nil,
                        :skip_metadata_check => skip_metadata_check,
                        :validate_contents => validate_contents)

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

    def find_products
      params.require(:ids)
      @products = Product.where(:id => params[:ids])
    end
  end
end
