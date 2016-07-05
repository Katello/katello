FactoryGirl.define do
  factory :puppet_module, :class => Katello::PuppetModule do
    name "trystero"
    author "tpynchon"
    sequence(:version) { |n| "1.2.#{n}" }
    sequence(:uuid)
  end
end
