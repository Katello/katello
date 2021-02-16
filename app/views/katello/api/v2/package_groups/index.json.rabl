object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends "katello/api/v2/package_groups/base"

  if params[:include_filter_ids]
    node(:filter_ids) { |package_group| package_group.content_view_package_group_filters.pluck(:id) }
  end
end
