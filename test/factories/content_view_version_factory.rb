FactoryGirl.define do
  factory :content_view_version, :class => Katello::ContentViewVersion do
    sequence(:version)
    content_view
  end
end
