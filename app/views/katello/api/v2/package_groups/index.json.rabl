object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends "katello/api/v2/package_groups/base"

  if (params[:show_all_for] == "content_view_filter" && @filter)
    node(:added_to_content_view_filter) { |package_group| package_group.in_content_view_filter?(@filter) }
  end
end
