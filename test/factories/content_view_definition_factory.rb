FactoryGirl.define do
  factory :content_view_definition do
    sequence(:name) {|n| "Database_definition#{n}" }
    description "Database content view definition"
    organization
  end
end
