FactoryBot.define do
  factory :katello_content_view_environment, :class => Katello::ContentViewEnvironment do
    sequence(:name) { |n| "name#{n}" }
    sequence(:label) { |n| "label#{n}" }
    association :content_view_version, :factory => :katello_content_view_version
  end
end
