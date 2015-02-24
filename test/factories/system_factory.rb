FactoryGirl.define do
  factory :katello_system, :class => Katello::System do
    cp_type "system"
    facts(:foo => 'bar')

    trait :alabama do
      name 'Alabama'
      cp_type "system"
      facts(:foo => 'bar')
    end

    trait :capsule do
      name 'capsule'
      uuid '1234-1234-1234-1234'
      cp_type 'system'
      facts('ip' => '192.168.0.1')
    end
  end
end
