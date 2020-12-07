object @capsule

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
    @capsule.environment_syncable?(env)
  end

  if @capsule.has_feature?(SmartProxy::PULP_NODE_FEATURE)
    node :counts do |env|
      counts = {
        :content_hosts => env.hosts.authorized("view_hosts").count,
        :content_views => env.content_views.non_default.count,
        :products => env.products.enabled.count
      }
      repo_data = @capsule.smart_proxy_service.current_repositories_data(env)
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
          :default => content_view.default,
          :counts => {
            :content_hosts => content_view.hosts.authorized("view_hosts").count,
            :products => content_view.products.enabled.count
          }
        }
        repo_data = @capsule.smart_proxy_service.current_repositories_data(env, content_view)
        attributes[:counts].merge!(Katello::Pulp::ContentCountsCalculator.new(repo_data).calculate)
        attributes
      end
    end
  end
end
