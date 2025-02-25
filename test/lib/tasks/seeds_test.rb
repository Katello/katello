require 'katello_test_helper'

module Katello
  module Seed
    class LocationsTest < ActiveSupport::TestCase
      setup do
        Location.destroy_all
      end

      def seed_location
        load "#{Katello::Engine.root}/db/seeds.d/101-locations.rb"
      end

      test 'with SEED_LOCATION' do
        with_env('SEED_LOCATION' => 'test_location_seed') { seed_location }
        assert Location.find_by_title('test_location_seed').present?
      end

      test 'without SEED_LOCATION' do
        seed_location
        # check that default_location_subscribed_hosts gets set
        assert_equal Setting['default_location_subscribed_hosts'], Location.first.title
      end
    end

    class PulpProxyTest < ActiveSupport::TestCase
      test "Make sure Pulpcore feature exists" do
        load "#{Katello::Engine.root}/db/seeds.d/104-proxy.rb"

        assert Feature.find_by_name('Pulpcore').present?
      end
    end

    class MailNotificationsTest < ActiveSupport::TestCase
      test "Make sure mail notification got setup" do
        load "#{Katello::Engine.root}/db/seeds.d/106-mail_notifications.rb"

        assert MailNotification[:host_errata_advisory]
        assert MailNotification[:promote_errata]
        assert MailNotification[:sync_errata]
      end
    end

    class SubscriptionBookmarkstest < ActiveSupport::TestCase
      test "Ensure hypervisor bookmark is created" do
        load "#{Katello::Engine.root}/db/seeds.d/108-subcription-bookmarks.rb"

        refute_empty Bookmark.where(:name => "list hypervisors")
      end
    end
  end
end
