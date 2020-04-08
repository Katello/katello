FactoryBot.define do
  factory :katello_pool, :class => Katello::Pool do
    active { true }
    end_date { Date.today + 1.year }
    cp_id { 1 }

    trait :with_organization do
      association :organization, :factory => :katello_organization
    end

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end

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

    trait :recently_expired do
      end_date { Date.today - Katello::Pool::DAYS_RECENTLY_EXPIRED }
    end

    trait :long_expired do
      end_date { Date.today - Katello::Pool::DAYS_RECENTLY_EXPIRED - 1 }
    end
  end
end
