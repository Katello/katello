FactoryBot.define do
  factory :katello_content_view_environment, :class => Katello::ContentViewEnvironment do
    # NOTE: When using this factory, you should provide:
    # - content_view_version: a content view version
    # - environment: the lifecycle environment
    # The content_view will be automatically set from the version

    content_view_version { association(:katello_content_view_version) }
    content_view { content_view_version.content_view }
    environment { association(:katello_environment, organization: content_view.organization) }
  end
end
