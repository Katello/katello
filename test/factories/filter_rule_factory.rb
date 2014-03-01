FactoryGirl.define do
  factory :katello_filter_rule, :class => Katello::FilterRule do
    association :filter, :factory => :katello_filter
    inclusion true
  end

  factory :katello_package_filter_rule, :class => Katello::PackageRule, :parent => :katello_filter_rule do
    parameters ({:units =>[{:name =>["g*"]}]}).with_indifferent_access
  end

  factory :katello_erratum_filter_rule, :class => Katello::ErratumRule, :parent => :katello_filter_rule do
  end

  factory :katello_package_group_filter_rule, :class => Katello::PackageGroupRule, :parent => :katello_filter_rule do
  end

  factory :katello_puppet_module_filter_rule, :class => Katello::PuppetModuleRule, :parent => :katello_filter_rule do
  end
end
