FactoryGirl.define do
  factory :katello_organization, :class => "Organization" do
    type "Organization"
    sequence(:name) { |n| "Organization#{n}" }
    sequence(:label) { |n| "org#{n}" }

    trait :acme_corporation do
      name "ACME_Corporation"
      type "Organization"
      description "This is the first Organization."
      label "acme_corporation_label"
    end

    trait :with_library do
      association :library, :factory => :katello_library
    end

    factory :acme_corporation,  :traits => [:acme_corporation]
  end
end
