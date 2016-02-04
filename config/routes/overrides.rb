module Katello
  class WhitelistConstraint
    PATHS = [%r{\A/api/v2/organizations/\S+/parameters}]

    def matches?(request)
      PATHS.map { |path| request.env["REQUEST_PATH"].match(path) }.any? ? false : true
    end
  end
end

Foreman::Application.routes.draw do
  override_message = '{"message": "Route forbidden by Katello, check katello/config/routes/overrides"}'

  match "/api/v2/organizations/*all", :to => proc { [404, {}, [override_message]] },
                                      :via => :get,
                                      :constraints => Katello::WhitelistConstraint.new

  match "/api/v1/organizations/:id", via: :delete, to: proc { [404, {}, [override_message]] }

  resources :operatingsystems, :only => [] do
    get 'available_kickstart_repo', :on => :member
  end

  resources :hosts, :only => [] do
    get 'puppet_environment_for_content_view', :on => :collection
  end

  resources :smart_proxies do
    member do
      get :pulp_storage
      get :pulp_status
    end
  end

  namespace :api do
    scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
      resources :hosts, :only => [] do
        member do
          put :host_collections
        end
      end
    end
  end

  scope :module => "katello" do
    namespace :api do
      scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
        resources :hosts, :only => [] do
          resources :errata, :only => [:show, :index], :controller => :host_errata do
            collection do
              put :apply
              get :auto_complete_search
            end
          end

          resources :packages, :only => [:index], :controller => :host_packages do
            get :auto_complete_search, :on => :collection

            collection do
              put :remove
              put :install
              put :upgrade
              put :upgrade_all
            end
          end

          resources :subscriptions, :only => [:index], :controller => :host_subscriptions do
            collection do
              put :auto_attach
              get :product_content
              get :events
              put :remove_subscriptions
              put :add_subscriptions
            end
          end
        end
      end
    end
  end
end
