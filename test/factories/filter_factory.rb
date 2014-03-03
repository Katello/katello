FactoryGirl.define do
  factory :katello_filter, :class => Katello::Filter do
    sequence(:name) {|n| "Database_filter#{n}" }
    content_view
    association :content_view_definition, :factory => :katello_content_view_definition
  end

  factory :package_filter, :class => Katello::PackageFilter, :parent => :filter do
  end

  factory :erratum_filter, :class => Katello::ErratumFilter, :parent => :filter do
  end

  factory :package_group_filter, :class => Katello::PackageGroupFilter, :parent => :filter do
  end
end
