object @resource

extends "katello/api/v2/flatpak_remote_repositories/base"

child :flatpak_remote => :flatpak_remote do
  attributes :id, :name, :url
end

if ::Foreman::Cast.to_bool params[:manifests]
  child :manifests => :manifests do
    attributes :name, :digest, :tags, :application, :runtime, :flatpak_ref
  end
end
