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
        assert_equal Setting.find_by_name('default_location_subscribed_hosts').value, Location.first.title
        # check that default_location_puppet_content gets set
        assert_equal Setting.find_by_name('default_location_puppet_content').value, Location.first.title
      end
    end

    class PulpProxyTest < ActiveSupport::TestCase
      setup do
        FactoryBot.create(:smart_proxy, :default_smart_proxy)
      end

      test "Make sure Pulp Proxy features exist" do
        load "#{Katello::Engine.root}/db/seeds.d/104-proxy.rb"

        assert Feature.find_by_name('Pulp').present?
        assert Feature.find_by_name('Pulp Node').present?
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

        refute Bookmark.where(:name => "list hypervisors").empty?
      end
    end

    class HttpProxyTest < ActiveSupport::TestCase
      def setup
        Setting[:content_default_http_proxy] = ""
        FactoryBot.create(:smart_proxy, :default_smart_proxy)
      end

      def run_proxy_seed
        load "#{Katello::Engine.root}/db/seeds.d/115-http_proxy.rb"
      end

      test "Clears out default setting if not configured" do
        SETTINGS[:katello][:cdn_proxy] = nil
        Setting[:content_default_http_proxy] = "the proxy that shouldn't exist"
        run_proxy_seed

        assert_empty Setting[:content_default_http_proxy]
      end

      test "Creates proxy and assigns if not existing" do
        refute ::HttpProxy.find_by(:name => 'foo.com')

        SETTINGS[:katello][:cdn_proxy] = {
          host: 'http://foo.com/',
          port: 1234
        }
        run_proxy_seed

        proxy = ::HttpProxy.find_by(:name => 'foo.com')
        assert proxy
        assert_equal 'http://foo.com:1234/', proxy.url

        assert_equal 'foo.com', Setting[:content_default_http_proxy]
      end

      test "Updates existing" do
        ::HttpProxy.create!(name: 'foo.com', url: 'http://foo.com')
        assert_empty Setting[:content_default_http_proxy]

        SETTINGS[:katello][:cdn_proxy] = {
          host: 'http://foo.com/',
          port: 5678,
          user: 'angry',
          password: 'sun'
        }
        run_proxy_seed

        proxy = ::HttpProxy.find_by(:name => 'foo.com')
        assert_equal 'angry', proxy.username
        assert_equal 'sun', proxy.password
        assert_equal 'http://foo.com:5678/', proxy.url
        assert_equal 'foo.com', Setting[:content_default_http_proxy]
      end
    end
  end
end
