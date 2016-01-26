object @capsule_content

attribute :last_sync_time

child :active_sync_tasks => :active_sync_tasks do
  extends 'foreman_tasks/api/tasks/show'
end
child :last_failed_sync_tasks => :last_failed_sync_tasks do
  extends 'foreman_tasks/api/tasks/show'
end

child @lifecycle_environments => :lifecycle_environments do
  extends 'katello/api/v2/common/identifier'
  extends 'katello/api/v2/common/org_reference'

  attributes :library
  node :syncable do |env|
    @capsule_content.environment_syncable?(env)
  end
  node :counts do |env|
    counts = {
      :content_hosts => env.systems.readable.count,
      :content_views => env.content_views.non_default.count,
      :products => env.products.enabled.count
    }
    repo_data = @capsule_content.pulp_repositories_data(env)
    counts.merge!(Katello::Pulp::ContentCountsCalculator.new(repo_data).calculate)
  end

  node :content_views do |env|
    env.content_views.map do |content_view|
      attributes = {
        :id => content_view.id,
        :label => content_view.label,
        :name => content_view.name,
        :composite => content_view.composite,
        :last_published => content_view.versions.empty? ? nil : content_view.versions.last.created_at,
        :counts => {
          :content_hosts => content_view.systems.readable.count,
          :products => content_view.products.enabled.count
        }
      }
      repo_data = @capsule_content.pulp_repositories_data(env, content_view)
      attributes[:counts].merge!(Katello::Pulp::ContentCountsCalculator.new(repo_data).calculate)
      attributes
    end
  end
end
