object @environment => :environment

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :library

node :prior do |env|
  if env.prior
    {name: env.prior.name, :id => env.prior.id}
  end
end

node :successor do |env|
  if !env.library && env.successor
    {name: env.successor.name, :id => env.successor.id}
  end
end

node :counts do |env|
  counts = {
    :content_hosts => env.systems.readable.count,
    :content_views => env.content_views.non_default.count
  }
  if env.library?
    repos = env.repositories.in_default_view
    counts[:packages] = Katello::Package.package_count(repos)
    counts[:puppet_modules] = Katello::PuppetModule.module_count(repos)
    counts[:errata] = partial('katello/api/v2/errata/counts', :object => Katello::RelationPresenter.new(Katello::Erratum.in_repositories(repos)))
    counts[:yum_repositories] = repos.yum_type.count
    counts[:docker_repositories] = repos.docker_type.count
    counts[:products] = env.organization.products.enabled.count
  end
  counts
end

node :permissions do |env|
  {
    :view_lifecycle_environments => env.readable?,
    :edit_lifecycle_environments => env.editable?,
    :destroy_lifecycle_environments => env.deletable?,
    :promote_or_remove_content_views_to_environments => env.promotable_or_removable?
  }
end

extends 'katello/api/v2/common/timestamps'
