object @resource

extends 'katello/api/v2/common/identifier'

attributes :name, :base_url, :subpaths, :content_type, :alternate_content_source_type, :smart_proxies, :upstream_username, :last_refreshed

child :latest_dynflow_refresh_task => :last_refresh do |_object|
  attributes :id, :username, :started_at, :ended_at, :state, :result, :progress
  node :last_refresh_words do |object|
    if (object.respond_to?('started_at') && object.started_at)
      time_ago_in_words(Time.parse(object.started_at.to_s))
    end
  end
end

if params.key?(:include_permissions)
  node :permissions do |alternate_content_source|
    {
      :view_alternate_content_sources => alternate_content_source.readable?,
      :edit_alternate_content_sources => alternate_content_source.editable?,
      :destroy_alternate_content_sources => alternate_content_source.deletable?
    }
  end
end
