FactoryGirl.define do
  factory :filter, :class => Katello::Filter do
    sequence(:name) {|n| "Database_filter#{n}" }
    content_view
  end

  factory :package_filter, :class => Katello::PackageFilter, :parent => :filter do
    parameters ({:units =>[{:name =>["g*"], :inclusion => true}]}).with_indifferent_access
  end

  factory :erratum_filter, :class => Katello::ErratumFilter, :parent => :filter do
  end

  factory :package_group_filter, :class => Katello::PackageGroupFilter, :parent => :filter do
  end
end
