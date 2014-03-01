FactoryGirl.define do
  factory :katello_filter, :class => Katello::Filter do
    sequence(:name) {|n| "Database_filter#{n}" }
    association :content_view_definition, :factory => :katello_content_view_definition
  end
end
