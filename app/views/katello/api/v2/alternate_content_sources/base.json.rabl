extends 'katello/api/v2/common/identifier'

if @object.respond_to?(:alternate_content_source_type)
  if @object.custom?
    attributes :name, :alternate_content_source_type, :content_type, :base_url, :subpaths, :upstream_username, :smart_proxies, :verify_ssl
    child :ssl_ca_cert => :ssl_ca_cert do |_object|
      attributes :id, :name
    end

    child :ssl_client_cert => :ssl_client_cert do |_object|
      attributes :id, :name
    end

    child :ssl_client_key => :ssl_client_key do |_object|
      attributes :id, :name
    end
  elsif @object.simplified?
    attributes :name, :alternate_content_source_type, :content_type, :products, :smart_proxies
  end
end

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
