require 'katello/api/mapper_extensions'

class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Katello::Engine.routes.draw do
  scope :module => :api do
    scope :module => :registry, :constraints => { :tag => /[0-9a-zA-Z\-_.:]*/, :digest => /[0-9a-zA-Z:]*/ } do
      match '/v2/token' => 'registry_proxies#token', :via => :get
      match '/v2/token' => 'registry_proxies#token', :via => :post
      match '/v2/*repository/manifests/:tag' => 'registry_proxies#pull_manifest', :via => :get
      match '/v2/*repository/manifests/:tag' => 'registry_proxies#push_manifest', :via => :put
      match '/v2/*repository/blobs/:digest' => 'registry_proxies#pull_blob', :via => :get
      match '/v2/*repository/blobs/:digest' => 'registry_proxies#check_blob', :via => :head
      match '/v2/*repository/blobs/uploads' => 'registry_proxies#start_upload_blob', :via => :post
      match '/v2/*repository/blobs/uploads/:uuid' => 'registry_proxies#finish_upload_blob', :via => :put
      match '/v2/*repository/blobs/uploads/:uuid' => 'registry_proxies#upload_blob', :via => :patch
      match '/v2/_catalog' => 'registry_proxies#catalog', :via => :get
      match '/v2/*repository/tags/list' => 'registry_proxies#tags_list', :via => :get
      match '/v2' => 'registry_proxies#ping', :via => :get
      match '/v1/_ping' => 'registry_proxies#v1_ping', :via => :get
      match '/v1/search' => 'registry_proxies#v1_search', :via => :get
    end
  end
end
