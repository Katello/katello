FactoryGirl.define do
  factory :content_view_version do
    sequence(:version)
    content_view
  end
end
