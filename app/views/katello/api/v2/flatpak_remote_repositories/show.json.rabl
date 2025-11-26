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

node(:repository_dependencies) do |repo|
  org = repo.flatpak_remote.organization
  repo.repository_dependencies.map do |dep|
    {
      id: dep.id,
      name: dep.name,
      label: dep.label,
      flatpak_remote_id: dep.flatpak_remote_id,
      exists_in_org: org.present? && ::Katello::Repository.in_organization(org).joins(:root).where(katello_root_repositories: { name: dep.name }).exists?,
    }
  end
end
