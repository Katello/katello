FactoryBot.define do
  factory :katello_content_view_version, :class => Katello::ContentViewVersion do
    sequence(:major)
    sequence(:minor)
    association :content_view, :factory => :katello_content_view
  end
end
