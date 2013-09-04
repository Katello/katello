require 'api/constraints/api_version_constraint'
require 'api/mapper_extensions'

class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Rails.application.routes.draw do

  namespace :api do
    scope :module => :v1, :constraints => ApiVersionConstraint.new(:version => 1, :default => true) do
      resources :nodes do
        member do
          post :sync
        end
        collection do
          get '/by_uuid/:uuid' => "nodes#show_by_uuid"
        end
        resources :capabilities, :controller=>'node_capabilities'
      end
    end

    scope :module => :v2, :constraints => ApiVersionConstraint.new(:version => 2) do

      api_resources :nodes do
        member do
          :sync
        end
        collection do
          get '/by_uuid/:uuid' => "nodes#show_by_uuid"
        end
        api_resources :capabilities, :controller=>'node_capabilities'
      end

    end
  end
end
