FactoryGirl.define do
  factory :user do

    trait :batman do
      username "batman"
      password "ihaveaterriblepassword"
      email    "batman@wayne.ent.com"
    end

  end
end
