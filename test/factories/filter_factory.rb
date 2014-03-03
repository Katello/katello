FactoryGirl.define do
  factory :katello_filter, :class => Katello::Filter do
    sequence(:name) {|n| "Database_filter#{n}" }
    association :content_view, :factory => :katello_content_view
  end

  factory :katello_package_filter, :class => Katello::PackageFilter, :parent => :filter do
  end

  factory :katello_erratum_filter, :class => Katello::ErratumFilter, :parent => :filter do
  end

  factory :katello_package_group_filter, :class => Katello::PackageGroupFilter, :parent => :filter do
  end
end
