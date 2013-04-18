FactoryGirl.define do
  factory :content_view_definition do
    sequence(:name) {|n| "Database_definition#{n}" }
    sequence(:label) {|n| "Database_definition#{n}" }
    description "Database content view definition"
    organization

    trait :composite do
      composite true
    end
  end
end
