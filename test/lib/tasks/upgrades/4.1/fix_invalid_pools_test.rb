require 'katello_test_helper'
require 'rake'

module Katello
  class FixInvalidPoolsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/4.1/fix_invalid_pools'
      Rake.application.rake_require 'katello/tasks/reimport' # needed for check_ping
      Rake::Task['katello:upgrades:4.1:fix_invalid_pools'].reenable
      Rake::Task.define_task(:environment)
      Rake::Task.define_task('dynflow:client')
      Rake::Task['katello:check_ping'].reenable
      Rake::Task['dynflow:client'].reenable
      Katello::Ping.expects(:ping).returns(:status => 'ok')
    end

    def test_import_pool_data
      org_one = taxonomies(:empty_organization)
      org_two = taxonomies(:organization2)

      subscription = org_one.subscriptions.first

      valid_pool = Katello::Pool.new(organization: org_one, subscription: subscription, cp_id: SecureRandom.uuid)
      invalid_pool = Katello::Pool.new(organization: org_two, subscription: subscription, cp_id: SecureRandom.uuid)

      valid_pool.save!
      invalid_pool.save!(validate: false)
      refute invalid_pool.valid?

      Katello::Subscription.expects(:import_all).with(org_one).never
      Katello::Subscription.expects(:import_all).with(org_two).once

      Katello::Resources::Candlepin::Pool.expects(:find).once.returns(
        'productId' => subscription.cp_id,
        'owner' => {
          'key' => org_one.label,
        }
      )
      Katello::Pool.any_instance.expects(:import_data).with(true).once

      Katello::Pool.expects(:all).returns([valid_pool, invalid_pool])

      Rake.application.invoke_task('katello:upgrades:4.1:fix_invalid_pools')
    end

    def test_delete_orphaned_by_org
      org_one = taxonomies(:empty_organization)
      org_two = taxonomies(:organization2)

      subscription = org_one.subscriptions.first

      invalid_pool = Katello::Pool.new(organization: org_two, subscription: subscription, cp_id: SecureRandom.uuid)
      invalid_pool.save!(validate: false)
      refute invalid_pool.valid?

      Katello::Subscription.expects(:import_all).with(org_one).never
      Katello::Subscription.expects(:import_all).with(org_two).once

      Katello::Resources::Candlepin::Pool.expects(:find).once.returns(
        'productId' => subscription.cp_id,
        'owner' => {
          'key' => nil, # org lookup will return nothing
        }
      )

      Katello::Pool.any_instance.expects(:import_data).never
      Katello::Pool.expects(:all).returns([invalid_pool])

      Rake.application.invoke_task('katello:upgrades:4.1:fix_invalid_pools')
    end

    def test_delete_no_matching_subscription
      org_one = taxonomies(:empty_organization)
      org_two = taxonomies(:organization2)

      subscription = org_one.subscriptions.first

      invalid_pool = Katello::Pool.new(organization: org_two, subscription: subscription, cp_id: SecureRandom.uuid)
      invalid_pool.save!(validate: false)
      refute invalid_pool.valid?

      Katello::Subscription.expects(:import_all).with(org_one).never
      Katello::Subscription.expects(:import_all).with(org_two).once

      Katello::Resources::Candlepin::Pool.expects(:find).once.returns(
        'productId' => '12354', # this returns nothing for the subscription lookup
        'owner' => {
          'key' => org_one.label,
        }
      )

      Katello::Pool.any_instance.expects(:import_data).never
      Katello::Pool.expects(:all).returns([invalid_pool])

      Rake.application.invoke_task('katello:upgrades:4.1:fix_invalid_pools')
    end

    def test_delete_orphaned_in_candlepin
      org_one = taxonomies(:empty_organization)
      org_two = taxonomies(:organization2)
      subscription = org_one.subscriptions.first

      invalid_pool = Katello::Pool.new(organization: org_two, subscription: subscription, cp_id: SecureRandom.uuid)
      invalid_pool.save!(validate: false)
      refute invalid_pool.valid?

      Katello::Subscription.expects(:import_all).with(org_one).never
      Katello::Subscription.expects(:import_all).with(org_two).once

      Katello::Resources::Candlepin::Pool.expects(:find).raises(Katello::Errors::CandlepinPoolGone)
      Katello::Pool.expects(:all).returns([invalid_pool])

      Rake.application.invoke_task('katello:upgrades:4.1:fix_invalid_pools')
    end
  end
end
