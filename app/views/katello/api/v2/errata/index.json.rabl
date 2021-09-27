object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends 'katello/api/v2/errata/show'

  if params[:include_filter_ids]
    node(:filter_ids) { |erratum| erratum.content_view_filters.pluck(:id) }
  end
end
