FactoryGirl.define do
  factory :environment_product do

    factory :library_fedora do
      association :environment
      association :product
    end

  end
end
