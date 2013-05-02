FactoryGirl.define do
  factory :environment_product do

    ignore do
      stubbed = true
    end

    trait :library_fedora do
      after_build do |environment_product|
        environment_product.environment = FactoryGirl.build_stubbed(:k_t_environment, :library) if stubbed
        environment_product.product     = FactoryGirl.build_stubbed(:product, :fedora) if stubbed
      end
    end

  end
end
