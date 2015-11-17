#:nocov:

module Katello
  class Ping
    OK_RETURN_CODE = 'ok'
    FAIL_RETURN_CODE = 'FAIL'
    PACKAGES = %w(katello candlepin pulp thumbslug qpid)

    SERVICES = [:pulp, :pulp_auth, :candlepin, :candlepin_auth, :foreman_tasks]

    class << self
      #
      # Calls "status" services in all backend engines.
      #
      # This should be called with User.current set if you want to check pulp_auth
      #
      # TODO: break up this method
      # rubocop:disable MethodLength
      def ping(services = SERVICES)
        result = { :status => OK_RETURN_CODE, :services => {}}
        services.each { |service| result[:services][service] = {} }

        # pulp - ping without oauth
        if services.include?(:pulp)
          exception_watch(result[:services][:pulp]) do
            Ping.pulp_without_oauth
          end
        end

        # candlepin - ping without oauth
        if services.include?(:candlepin)
          url = SETTINGS[:katello][:candlepin][:url]
          exception_watch(result[:services][:candlepin]) do
            RestClient.get "#{url}/status"
          end
        end

        # pulp - ping with oauth
        if User.current && services.include?(:pulp_auth)
          exception_watch(result[:services][:pulp_auth]) do
            if result[:services][:pulp][:status] == OK_RETURN_CODE
              Katello.pulp_server.resources.user.retrieve_all
            else
              fail _("Skipped pulp_auth check after failed pulp check")
            end
          end
        else
          result[:services].delete(:pulp_auth)
        end

        if services.include?(:candlepin_auth)
          # candlepin - ping with oauth
          exception_watch(result[:services][:candlepin_auth]) do
            Katello::Resources::Candlepin::CandlepinPing.ping
          end
        end

        if services.include?(:foreman_tasks)
          exception_watch(result[:services][:foreman_tasks]) do
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

        # set overall status result code
        result[:services].each_value do |v|
          result[:status] = FAIL_RETURN_CODE unless v[:status] == OK_RETURN_CODE
        end
        result
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

      # this checks Pulp is running and responding without need
      # for authentication. We don't use RestClient.options here
      # because it returns empty string, which is not enough to say
      # pulp is the one that responded
      def pulp_without_oauth
        body = RestClient.get("#{SETTINGS[:katello][:pulp][:url]}/status/")
        fail _("Pulp does not appear to be running.") if body.empty?
        json = JSON.parse(body)

        if json['known_workers'].empty?
          fail _("No pulp workers running.")
        end

        if json['database_connection'] && json['database_connection']['connected'] != true
          fail _("Pulp database connection issue.")
        end

        if json['messaging_connection'] && json['messaging_connection']['connected'] != true
          fail _("Pulp message bus connection issue.")
        end

        json
      end
    end
  end
end

#:nocov:
