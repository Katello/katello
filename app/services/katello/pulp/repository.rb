module Katello
  module Pulp
    class Repository < ::Actions::Pulp::Abstract
      attr_accessor :repo

      def initialize(repo, smart_proxy = nil)
        @repo = repo
        @smart_proxy = smart_proxy
      end

      def sync(overrides = {})
        sync_options = {}
        sync_options[:max_speed] = SETTINGS.dig(:katello, :pulp, :sync_KBlimit)
        sync_options[:num_threads] = SETTINGS.dig(:katello, :pulp, :sync_threads)
        sync_options[:feed] = overrides[:source_url] if overrides[:source_url]
        sync_options[:validate] = !SETTINGS.dig(:katello, :pulp, :skip_checksum_validation)
        sync_options.merge!(overrides[:options]) if overrides[:options]
        [::Katello::CapsuleContent.new(@smart_proxy).pulp_server.resources.repository.sync(@repo.pulp_id, override_config: sync_options.compact!)]
      end
    end
  end
end
