FactoryGirl.define do
  factory :katello_pool, :class => Katello::Pool do
    trait :active do
      active true
    end

    trait :inactive do
      active false
    end

    trait :unexpired do
      end_date Date.today + 1.days
    end

    trait :expired do
      end_date Date.today
    end

    trait :expiring_soon do
      end_date Date.today + Katello::Pool::DAYS_EXPIRING_SOON
    end

    trait :not_expiring_soon do
      end_date Date.today + Katello::Pool::DAYS_EXPIRING_SOON + 1
    end

    trait :recently_expired do
      end_date Date.today - Katello::Pool::DAYS_RECENTLY_EXPIRED
    end

    trait :long_expired do
      end_date Date.today - Katello::Pool::DAYS_RECENTLY_EXPIRED - 1
    end
  end
end
