module Katello
  class Ping
    OK_RETURN_CODE = 'ok'.freeze
    FAIL_RETURN_CODE = 'FAIL'.freeze
    PACKAGES = %w(katello candlepin pulp foreman hammer dynflow).freeze

    class << self
      def services(capsule_id = nil)
        proxy = fetch_proxy(capsule_id)
        services = [:candlepin, :candlepin_auth, :foreman_tasks, :katello_events, :candlepin_events]
        services += [:pulp3, :pulp3_content] if proxy&.pulp3_enabled?

        services
      end

      def ping(services: nil, capsule_id: nil)
        ping_services_for_capsule(services, capsule_id)
      end

      def ping!(services: nil, capsule_id: nil)
        result = ping_services_for_capsule(services, capsule_id)

        if result[:status] != OK_RETURN_CODE
          failed_names = failed_services(result).keys
          fail Katello::Errors::PingError, "The following services have not been started or are reporting errors: #{failed_names.join(', ')}"
        end

        result
      end

      def status
        {
          version: Katello::VERSION,
          timeUTC: Time.now.getutc,
        }
      end

      def event_daemon_status(status, result)
        running = status&.dig(:running)

        if running
          result[:message] = "#{status[:processed_count].to_i} Processed, #{status[:failed_count].to_i} Failed"
        else
          result[:status] = FAIL_RETURN_CODE
          result[:message] = _("Not running")
        end
      end

      def ping_katello_events(result)
        exception_watch(result) do
          status = Katello::EventDaemon::Runner.service_status(:katello_events)
          event_daemon_status(status, result)
        end
      end

      def ping_candlepin_events(result)
        exception_watch(result) do
          status = Katello::EventDaemon::Runner.service_status(:candlepin_events)
          event_daemon_status(status, result)
        end
      end

      def ping_pulp3_without_auth(service_result, capsule_id)
        exception_watch(service_result) do
          Katello::Ping.pulp3_without_auth(fetch_proxy(capsule_id).pulp3_url)
        end
      end

      def ping_pulp3_content_without_auth(service_result, capsule_id)
        exception_watch(service_result) do
          Katello::Ping.pulp3_content_without_auth(fetch_proxy(capsule_id).pulp3_url)
        end
      end

      def ping_candlepin_without_auth(service_result)
        url = SETTINGS[:katello][:candlepin][:url]
        exception_watch(service_result) do
          status = backend_status(url, :candlepin)
          check_candlepin_status(status)
        end
      end

      def ping_candlepin_with_auth(service_result)
        exception_watch(service_result) do
          status = Katello::Resources::Candlepin::CandlepinPing.ping
          check_candlepin_status(status)
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
          if checks.any?(&:rejected?)
            fail _("some executors are not responding, check %{status_url}") % { :status_url => '/foreman_tasks/dynflow/status' }
          end
        end
      end

      def check_candlepin_status(status)
        if status[:mode] != 'NORMAL'
          fail _("Candlepin is not running properly")
        end
      end

      # check for exception - set the result code properly
      def exception_watch(result)
        start = Time.new
        result[:status] = OK_RETURN_CODE
        yield
        result[:duration_ms] = ((Time.new - start) * 1000).round.to_s
        result
      rescue => e
        Rails.logger.warn(e.backtrace ? [e.message, e.backtrace].join("\n") : e.message)
        result[:status] = FAIL_RETURN_CODE
        result[:message] = e.message
        result
      end

      # get package information for katello and its components
      def packages
        names = PACKAGES.join("|")
        packages = `rpm -qa | egrep "#{names}"`
        packages.split("\n").sort
      end

      def pulp3_without_auth(url)
        json = backend_status(url, :pulp)
        fail _("Pulp does not appear to be running at %s.") % url if json.empty?

        if json['database_connection'] && json['database_connection']['connected'] != true
          fail _("Pulp database connection issue at %s.") % url
        end

        if json['redis_connection'] && json['redis_connection']['connected'] != true
          fail _("Pulp redis connection issue at %s.") % url
        end

        workers = json["online_workers"] || []
        fail _("No pulpcore workers are running at %s.") % url if workers.empty?

        json
      end

      def pulp3_content_without_auth(url)
        json = backend_status(url, :pulp)
        fail _("Pulp does not appear to be running at %s.") % url if json.empty?

        content_apps = json["online_content_apps"] || []
        fail _("No pulpcore content apps are running at %s.") % url if content_apps.empty?

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

      private

      def failed_services(result)
        result[:services].select do |_name, details|
          details[:status] != OK_RETURN_CODE
        end
      end

      def ping_services_for_capsule(services, capsule_id)
        services ||= self.services(capsule_id)
        result = {}
        services.each { |service| result[service] = {} }

        ping_pulp3_without_auth(result[:pulp3], capsule_id) if result.include?(:pulp3)
        ping_pulp3_content_without_auth(result[:pulp3_content], capsule_id) if result.include?(:pulp3_content)
        ping_candlepin_without_auth(result[:candlepin]) if result.include?(:candlepin)

        ping_candlepin_with_auth(result[:candlepin_auth]) if result.include?(:candlepin_auth)
        ping_foreman_tasks(result[:foreman_tasks]) if result.include?(:foreman_tasks)
        ping_katello_events(result[:katello_events]) if result.include?(:katello_events)
        ping_candlepin_events(result[:candlepin_events]) if result.include?(:candlepin_events)

        # set overall status result code
        result = {:services => result}
        result[:status] = result[:services].each_value.any? { |v| v[:status] == FAIL_RETURN_CODE } ? FAIL_RETURN_CODE : OK_RETURN_CODE
        result
      end

      def fetch_proxy(capsule_id)
        capsule_id ? SmartProxy.unscoped.find(capsule_id) : SmartProxy.pulp_primary
      end

      def backend_status(url, backend)
        ca_file = ::Cert::Certs.backend_ca_cert_file(backend)
        request_id = ::Logging.mdc['request']

        options = {}
        options[:ssl_ca_file] = ca_file unless ca_file.nil?
        options[:headers] = { 'Correlation-ID' => request_id } if request_id
        client = RestClient::Resource.new("#{url}/status/", options)

        response = client.get
        response.empty? ? {} : JSON.parse(response).with_indifferent_access
      end
    end
  end
end
