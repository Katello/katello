require 'katello/api/mapper_extensions'

class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Fort::Engine.routes.draw do

  namespace :api do
    scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v1|v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do

      api_resources :nodes do
        member do
          post :sync
        end
        collection do
          get '/by_uuid/:uuid' => "nodes#show_by_uuid"
        end
        api_resources :capabilities, :controller => 'node_capabilities'
      end

    end
  end
end
