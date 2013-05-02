FactoryGirl.define do
  factory :role do

    factory :administrator do
      name        "ADMINISTRATOR"
      description "Super administrator with all access."
      locked      true
    end

  end
end
