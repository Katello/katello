object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends 'katello/api/v2/module_streams/base'

  if params[:include_filter_ids]
    node(:filter_ids) { |module_stream| module_stream.content_view_filters.pluck(:id) }
  end
end
