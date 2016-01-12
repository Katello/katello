FactoryGirl.define do
  factory :capsule_feature, :parent => :feature do
    factory :pulp_feature do
      name "pulp"
    end
  end

  factory :capsule, :parent => :smart_proxy do
    factory :pulp_capsule do
      features { |c| [c.association(:pulp_feature)]}
    end
  end
end
