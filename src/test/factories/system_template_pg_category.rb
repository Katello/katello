FactoryGirl.define do
  factory :system_template_pg_category do

    sequence(:name) { |n| "SystemTemplatePgCategory#{n}" }

  end
end
