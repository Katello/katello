FactoryGirl.define do
  factory :katello_content_view_definition, :class => Katello::ContentViewDefinition do
    sequence(:name) {|n| "Database_definition#{n}" }
    sequence(:label) {|n| "Database_definition#{n}" }
    description "Database content view definition"
    association :organization, :factory => :katello_organization

    trait :composite do
      composite true
    end
  end
end
