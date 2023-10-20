object @capsule

attribute :last_sync_time
node :last_sync_words do |_object|
  @capsule&.last_sync_time ? time_ago_in_words(Time.parse(@capsule&.last_sync_time&.to_s)) : nil
end

attribute :download_policy

node :unsyncable_content_types do
  ::Katello::SmartProxyHelper.new(@capsule).unsyncable_content_types
end

child :active_sync_tasks => :active_sync_tasks do
  extends 'foreman_tasks/api/tasks/show'
end
child :last_failed_sync_tasks => :last_failed_sync_tasks do
  extends 'foreman_tasks/api/tasks/show'
end

child :last_sync_task => :last_sync_task do
  extends 'foreman_tasks/api/tasks/show'
end

node :content_counts do
    @capsule.content_counts
end

child @lifecycle_environments => :lifecycle_environments do
  extends 'katello/api/v2/common/identifier'
  extends 'katello/api/v2/common/org_reference'

  attributes :library
  node :syncable do |env|
    @capsule.environment_syncable?(env)
  end

  if @capsule.has_feature?(SmartProxy::PULP_NODE_FEATURE) || @capsule.has_feature?(SmartProxy::PULP3_FEATURE)
    node :counts do |env|
      {
        :content_views => env.content_views.non_default.count,
      }
    end

    node :content_views do |env|
      env.content_views.ignore_generated.map do |content_view|
        cvv = ::Katello::ContentViewVersion.in_environment(env).find_by(:content_view => content_view)
        attributes = {
          :id => content_view.id,
          :cvv_id => cvv&.id,
          :cvv_version => cvv&.version,
          :label => content_view.label,
          :name => content_view.name,
          :composite => content_view.composite,
          :last_published => content_view.versions.empty? ? nil : content_view.versions.in_environment(env).first&.created_at,
          :default => content_view.default,
          :up_to_date => @capsule.repos_pending_sync(env, content_view).empty?,
          :counts => {
            :repositories => ::Katello::ContentViewVersion.in_environment(env).find_by(:content_view => content_view)&.archived_repos&.count
          },
          :repositories => ::Katello::ContentViewVersion.in_environment(env)&.find_by(:content_view => content_view)&.archived_repos&.map do |repo|
                             {
                               :id => repo.id,
                               :name => repo.name,
                               :library_id => repo.library_instance_id
                             }
                           end
        }
        attributes
      end
    end
  end
end
