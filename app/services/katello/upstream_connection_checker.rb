module Katello
  class UpstreamConnectionChecker
    POSSIBLE_EXCEPTIONS = [
      Katello::Errors::DisconnectedMode,
      Katello::Errors::ManifestExpired,
      Katello::Errors::UpstreamConsumerGone,
      Katello::Errors::NoManifestImported
    ].freeze

    def initialize(organization)
      @organization = organization
    end

    def can_connect?
      assert_connection
    rescue StandardError => e
      if POSSIBLE_EXCEPTIONS.include?(e.class)
        false
      else
        raise e
      end
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
      ::Organization.as_org(@organization) do
        Katello::Resources::Candlepin::UpstreamConsumer.ping
      end
    end

    def assert_unexpired_manifest
      fail Katello::Errors::ManifestExpired if @organization.manifest_expired?
    end
  end
end
