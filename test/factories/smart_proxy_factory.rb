FactoryGirl.modify do
  factory :smart_proxy do
    transient do
      download_policy 'on_demand'
    end
  end
end
