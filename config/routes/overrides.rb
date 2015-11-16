module Katello
  class WhitelistConstraint
    PATHS = [/^\/api\/v2\/organizations\/\S+\/parameters/]

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

  scope :module => "katello" do
    namespace :api do
      scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
        resources :hosts, :only => [] do
          resources :packages, :only => [:index], :controller => :host_packages do
            collection do
              put :remove
              put :install
              put :upgrade
              put :upgrade_all
            end
          end
        end
      end
    end
  end
end
