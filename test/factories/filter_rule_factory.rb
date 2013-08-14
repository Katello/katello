FactoryGirl.define do
  factory :filter_rule do
    association :filter
    inclusion true
  end

  factory :package_filter_rule, :class => PackageRule, :parent => :filter_rule do
    parameters ({:units =>[{:name =>["g*"]}]}).with_indifferent_access
  end

  factory :erratum_filter_rule, :class => ErratumRule, :parent => :filter_rule do
  end

  factory :package_group_filter_rule, :class => PackageGroupRule, :parent => :filter_rule do
  end

  factory :puppet_module_filter_rule, :class => PuppetModuleRule, :parent => :filter_rule do
  end
end