FactoryGirl.define do
  factory :katello_content_view, :class => Katello::ContentView do
    sequence(:name) { |n| "Database#{n}" }
    description "This content view is for database content"
    association :organization, :factory => :katello_organization

    trait :composite do
      composite true
    end
  end
end
