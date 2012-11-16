FactoryGirl.define do
  factory :user do

    trait :batman do
      username  "batman"
      password  "ihaveaterriblepassword"
      email     "batman@wayne.ent.com"
      remote_id "batman"
    end

  end
end
