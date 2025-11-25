require 'katello_test_helper'

module Katello
  module Host
    class InfoProviderTest < ActiveSupport::TestCase
      def setup
        @host = FactoryBot.create(:host, :with_content, :with_subscription)
        @provider = Katello::Host::InfoProvider.new(@host)
      end

      def test_host_info_includes_rhsm_url_when_available
        Setting[:foreman_url] = 'https://foreman.example.com'
        proxy = FactoryBot.create(:smart_proxy, :with_pulp3)
        @host.content_facet.content_source = proxy
        @host.save!

        info = @provider.host_info

        assert_includes info['parameters'], 'rhsm_url'
        assert_equal 'https://foreman.example.com/rhsm', info['parameters']['rhsm_url']
      end

      def test_host_info_skips_rhsm_url_when_https_validation_fails
        Setting[:foreman_url] = 'http://foreman.example.com'
        proxy = FactoryBot.create(:smart_proxy, :with_pulp3)
        @host.content_facet.content_source = proxy
        @host.save!

        # Expect logger error from both smart_proxy_extensions.rb and info_provider.rb
        Rails.logger.expects(:error).with(regexp_matches(/RHSM HTTPS validation failed for Smart Proxy/))
        Rails.logger.expects(:error).with(regexp_matches(/Failed to retrieve RHSM URL for host/))

        info = @provider.host_info

        refute_includes info['parameters'], 'rhsm_url'
      end

      def test_host_info_continues_with_other_parameters_when_rhsm_url_fails
        Setting[:foreman_url] = 'http://foreman.example.com'
        proxy = FactoryBot.create(:smart_proxy, :with_pulp3)
        @host.content_facet.content_source = proxy
        @host.save!

        # Expect logger errors from both locations
        Rails.logger.expects(:error).with(regexp_matches(/RHSM HTTPS validation failed for Smart Proxy/))
        Rails.logger.expects(:error).with(regexp_matches(/Failed to retrieve RHSM URL for host/))

        info = @provider.host_info

        # Verify other parameters are still present (like host_collections)
        refute_includes info['parameters'], 'rhsm_url'
        assert info['parameters'].key?('foreman_host_collections')
      end
    end
  end
end
