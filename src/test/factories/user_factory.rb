FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@katello.org" }
    password "password1"
    remote_id "remote1"

    trait :batman do
      username  "batman"
      password  "ihaveaterriblepassword"
      email     "batman@wayne.ent.com"
      remote_id "batman"
    end

  end
end
