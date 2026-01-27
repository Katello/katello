FactoryBot.define do
  factory :katello_content_view_auto_publish_request, class: Katello::ContentViewAutoPublishRequest do
    association :content_view, factory: :katello_content_view
    association :content_view_version, factory: :katello_content_view_version
  end
end
