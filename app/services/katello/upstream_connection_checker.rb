module Katello
  class UpstreamConnectionChecker
    def initialize(organization)
      @organization = organization
    end

    def assert_connection
      assert_connected
      assert_unexpired_manifest
      assert_can_upstream_ping

      true
    end

    private

    def assert_connected
      fail Katello::Errors::DisconnectedMode if Setting[:content_disconnected]
    end

    def assert_can_upstream_ping
      Katello::Resources::Candlepin::UpstreamConsumer.ping
    end

    def assert_unexpired_manifest
      fail Katello::Errors::ManifestExpired if @organization.manifest_expired?
    end
  end
end
