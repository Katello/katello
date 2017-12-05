FactoryBot.define do
  factory :katello_content, :class => Katello::Content do
    sequence(:label) { |n| "content-label#{n}" }
  end
end
