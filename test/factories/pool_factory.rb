FactoryBot.define do
  factory :katello_pool, :class => Katello::Pool do
    start_date { 1.day.ago }
    end_date { Date.today + 1.year }
    sequence(:cp_id) { |n| n }
    pool_type { "normal" }
    quantity { 10 }
    account_number { 512_387 }
    contract_number { 6_208_983 }

    association :organization, :factory => :katello_organization

    subscription { association(:katello_subscription, organization: @instance.organization) }

    trait :unexpired do
      end_date { Date.today + 1.day }
    end

    trait :expired do
      end_date { Date.today }
    end

    trait :expiring_soon do
      end_date { Date.today + (Setting[:expire_soon_days] || 120) }
    end

    trait :expiring_in_12_days do
      end_date { Date.today + 12 }
    end

    trait :not_expiring_soon do
      end_date { Date.today + (Setting[:expire_soon_days] || 120) + 1 }
    end
  end
end
