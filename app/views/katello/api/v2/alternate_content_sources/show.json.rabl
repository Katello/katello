object @resource

attributes :id, :name, :label, :base_url, :subpaths, :content_type, :alternate_content_source_type, :smart_proxies

node :permissions do |alternate_content_source|
  {
    :view_alternate_content_sources => alternate_content_source.readable?,
    :edit_alternate_content_sources => alternate_content_source.editable?,
    :destroy_alternate_content_sources => alternate_content_source.deletable?
  }
end