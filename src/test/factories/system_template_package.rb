FactoryGirl.define do
  factory :system_template_package do

    sequence(:package_name) { |n| "SystemTemplatePackage#{n}" }

  end
end
