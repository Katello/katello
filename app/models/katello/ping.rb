#:nocov:

module Katello
  class Ping
    OK_RETURN_CODE = 'ok'.freeze
    FAIL_RETURN_CODE = 'FAIL'.freeze
    PACKAGES = %w(katello candlepin pulp qpid foreman tfm hammer).freeze

    SERVICES = [:pulp, :pulp_auth, :candlepin, :candlepin_auth, :foreman_tasks].freeze

    class << self
      #
      # Calls "status" services in all backend engines.
      #
      # This should be called with User.current set if you want to check pulp_auth
      def ping(services: SERVICES, capsule_id: nil)
        result = {}
        services.each { |service| result[service] = {} }
        result.delete(:pulp_auth) unless User.current

        ping_pulp_without_auth(result[:pulp], capsule_id) if result.include?(:pulp)
        ping_candlepin_without_auth(result[:candlepin]) if result.include?(:candlepin)

        ping_pulp_with_auth(result[:pulp_auth], result[:pulp][:status]) if result.include?(:pulp_auth)
        ping_candlepin_with_auth(result[:candlepin_auth]) if result.include?(:candlepin_auth)
        ping_foreman_tasks(result[:foreman_tasks]) if result.include?(:foreman_tasks)

        # set overall status result code
        result = {:services => result}
        result[:services].each_value do |v|
          result[:status] = v[:status] == OK_RETURN_CODE ? OK_RETURN_CODE : FAIL_RETURN_CODE
        end
        result
      end

      def ping_pulp_without_auth(service_result, capsule_id)
        exception_watch(service_result) do
          Ping.pulp_without_auth(pulp_url(capsule_id))
        end
      end

      def ping_candlepin_without_auth(service_result)
        url = SETTINGS[:katello][:candlepin][:url]
        exception_watch(service_result) do
          RestClient.get "#{url}/status"
        end
      end

      def ping_pulp_with_auth(service_result, pulp_without_auth_status)
        exception_watch(service_result) do
          if pulp_without_auth_status == OK_RETURN_CODE
            Katello.pulp_server.resources.user.retrieve_all
          else
            fail _("Skipped pulp_auth check after failed pulp check")
          end
        end
      end

      def ping_candlepin_with_auth(service_result)
        exception_watch(service_result) do
          Katello::Resources::Candlepin::CandlepinPing.ping
        end
      end

      def ping_foreman_tasks(service_result)
        exception_watch(service_result) do
          timeout   = 2
          world     = ForemanTasks.dynflow.world
          executors = world.coordinator.find_worlds(true)
          if executors.empty?
            fail _("foreman-tasks service not running or is not ready yet")
          end

          checks = executors.map { |executor| world.ping(executor.id, timeout) }
          checks.each(&:wait)
          if checks.any?(&:failed?)
            fail _("some executors are not responding, check %{status_url}") % { :status_url => '/foreman_tasks/dynflow/status' }
          end
        end
      end

      # check for exception - set the result code properly
      def exception_watch(result)
        start = Time.new
        yield
        result[:status] = OK_RETURN_CODE
        result[:duration_ms] = ((Time.new - start) * 1000).round.to_s
      rescue => e
        Rails.logger.warn(e.backtrace ? [e.message, e.backtrace].join("\n") : e.message)
        result[:status] = FAIL_RETURN_CODE
        result[:message] = e.message
      end

      # get package information for katello and its components
      def packages
        names = PACKAGES.join("|")
        packages = `rpm -qa | egrep "#{names}"`
        packages.split("\n").sort
      end

      def pulp_url(capsule_id)
        if capsule_id
          capsule_content = ::Katello::CapsuleContent.new(SmartProxy.find(capsule_id))
          uri = URI.parse(capsule_content.pulp_url)
          "#{uri.scheme}://#{uri.host.downcase}/pulp/api/v2"
        else
          SETTINGS[:katello][:pulp][:url]
        end
      end

      # this checks Pulp is running and responding without need
      # for authentication. We don't use RestClient.options here
      # because it returns empty string, which is not enough to say
      # pulp is the one that responded
      def pulp_without_auth(url)
        body = RestClient.get("#{url}/status/")
        fail _("Pulp does not appear to be running.") if body.empty?
        json = JSON.parse(body)

        if json['database_connection'] && json['database_connection']['connected'] != true
          fail _("Pulp database connection issue.")
        end

        if json['messaging_connection'] && json['messaging_connection']['connected'] != true
          fail _("Pulp message bus connection issue.")
        end

        unless all_pulp_workers_present?(json)
          fail _("Not all necessary pulp workers running.")
        end

        json
      end

      def all_pulp_workers_present?(json)
        worker_ids = json["known_workers"].collect { |worker| worker["_id"] }
        return false unless worker_ids.any?
        scheduler = worker_ids.any? { |worker| worker.include?("scheduler@") }
        resource_manager = worker_ids.any? { |worker| worker.include?("resource_manager@") }
        reservered_resource_worker = worker_ids.any? { |worker| worker =~ /reserved_resource_worker-./ }
        scheduler && resource_manager && reservered_resource_worker
      end
    end
  end
end

#:nocov:
