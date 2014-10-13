Bastion::Engine.routes.draw do
  class BastionPagesConstraint
    def initialize
      @pages = %w(
        activation_keys
        content_hosts
        content_views
        errata
        gpg_keys
        lifecycle_environments
        products
        subscriptions
        sync_plans
        host_collections
        katello_tasks
      )
    end

    def matches?(request)
      @pages.include?(request.params[:bastion_page])
    end
  end

  match '/:bastion_page/(*path)', :to => "bastion#index", constraints: BastionPagesConstraint.new
  match '/bastion/(*path)', :to => "bastion#index_ie"
end
