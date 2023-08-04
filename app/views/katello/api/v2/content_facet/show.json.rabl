child :content_facet => :content_facet_attributes do
  extends 'katello/api/v2/content_facet/base'

  node do |content_facet|
    content_facet.single_content_view # just so Rails gives a warning and we remember to fix this
    version = content_facet.content_view_environments.first&.content_view_version
    if version.present?
      {
        :content_view_version => version.version,
        :content_view_version_id => version.id,
        :content_view_version_latest => version.latest?
      }
    end
  end

  node :content_view_default? do |content_facet|
    content_facet.single_content_view&.default? || false
  end

  node :lifecycle_environment_library? do |content_facet|
    content_facet.single_lifecycle_environment&.library? || false
  end

  node :katello_agent_installed do |content_facet|
    content_facet.katello_agent_installed?
  end

  node :katello_tracer_installed do |content_facet|
    content_facet.tracer_installed?
  end

  node :katello_agent_enabled do
    Katello.with_katello_agent?
  end

  user = User.current # current_user is not available here
  child :permissions do
    node(:view_lifecycle_environments) { user.can?("view_lifecycle_environments") }
    node(:view_content_views) { user.can?("view_content_views") }
    node(:promote_or_remove_content_views_to_environments) { user.can?("promote_or_remove_content_views_to_environments") }
    node(:view_host_collections) { user.can?("view_host_collections") }
    node(:create_job_invocations) { user.can?("create_job_invocations") }
    node(:view_activation_keys) { user.can?("view_activation_keys") }
    node(:view_products) { user.can?("view_products") }
    node(:create_bookmarks) { user.can?("create_bookmarks") }
  end
end

attributes :description, :facts
