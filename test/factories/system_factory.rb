FactoryGirl.define do
  factory :katello_system, :class => Katello::System do
    trait :alabama do
      name 'Alabama'
    end

    trait :capsule do
      name 'capsule'
      uuid '1234-1234-1234-1234'
      cp_type 'system'
      facts('ip' => '192.168.0.1')
    end
  end
end
