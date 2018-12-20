require 'katello_test_helper'

module Katello
  class SeedsTest < ActiveSupport::TestCase
    setup do
      Setting.stubs(:[]).with(:administrator).returns("root@localhost")
      Setting.stubs(:[]).with(:send_welcome_email).returns(false)
      Setting.stubs(:[]).with(regexp_matches(/katello_default_/)).returns("Crazy Template")
      Setting.stubs(:[]).with(:default_location_subscribed_hosts).returns('')
      Setting.stubs(:[]).with(:default_location_puppet_content).returns('')
      Setting.stubs(:[]).with(:authorize_login_delegation_auth_source_user_autocreate).returns('EXTERNAL')
      Setting.stubs(:[]).with(:entries_per_page).returns(20)
    end

    def seed
      # Authorisation is disabled usually when run from a rake db:* task
      User.current = FactoryBot.build(:user, :admin => true,
                                       :organizations => [], :locations => [])
      load File.expand_path("#{Rails.root}/db/seeds.rb", __FILE__)
    end

    teardown do
      User.current = nil
    end
  end

  class LocationsTest < SeedsTest
    setup do
      Location.destroy_all
    end

    test 'with SEED_LOCATION' do
      with_env('SEED_LOCATION' => 'test_location_seed') { seed }
      assert Location.find_by_title('test_location_seed').present?
    end

    test 'without SEED_LOCATION' do
      seed
      # check that default_location_subscribed_hosts gets set
      assert_equal Setting.find_by_name('default_location_subscribed_hosts').value, Location.first.title
      # check that default_location_puppet_content gets set
      assert_equal Setting.find_by_name('default_location_puppet_content').value, Location.first.title
    end
  end

  class PulpProxyTest < SeedsTest
    test "Make sure Pulp Proxy features exist" do
      seed
      assert Feature.find_by_name('Pulp').present?
      assert Feature.find_by_name('Pulp Node').present?
    end
  end

  class MailNotificationsTest < SeedsTest
    test "Make sure mail notification got setup" do
      seed
      assert MailNotification[:host_errata_advisory]
      assert MailNotification[:promote_errata]
      assert MailNotification[:sync_errata]
    end
  end

  class SubscriptionBookmarkstest < SeedsTest
    test "Ensure hypervisor bookmark is created" do
      seed
      refute Bookmark.where(:name => "list hypervisors").empty?
    end
  end
end
