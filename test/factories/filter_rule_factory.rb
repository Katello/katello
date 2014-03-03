FactoryGirl.define do
  factory :katello_package_filter_rule, :class => Katello::PackageFilterRule do
    sequence(:name) { |n| "package #{n}"}
  end

  factory :katello_package_group_filter_rule, :class => Katello::PackageGroupFilterRule do
    sequence(:name) { |n| "package group #{n}"}
  end

  factory :katello_erratum_filter_rule, :class => Katello::ErratumFilterRule do
    sequence(:errata_id) { |n| "RHBA-2014-#{n}"}
  end
end
