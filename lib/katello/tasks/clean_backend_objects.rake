namespace :katello do
  desc "Cleans backend objects (hosts) that are missing in one or more backend systems."
  task :clean_backend_objects => ["dynflow:client", "environment", "check_ping"] do
    User.current = User.anonymous_admin

    puts "Cleaning backend objects"

    task = ForemanTasks.sync_task(::Actions::Candlepin::Consumer::CleanBackendObjects)

    results = task.output[:results]

    puts "Results:"
    puts "Hosts with nil facets: #{results[:hosts_with_nil_facets].length}"
    puts "Hosts with no subscriptions: #{results[:hosts_with_no_subscriptions].length}"
    puts "Orphaned consumers: #{results[:orphaned_consumers].length}"
    puts "Errors: #{results[:errors].length}"

    if results[:errors].any?
      results[:errors].each do |error|
        Rails.logger.error("#{error[:type]}: #{error[:message]}")
      end
    end
  end
end
