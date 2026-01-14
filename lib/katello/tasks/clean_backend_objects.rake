namespace :katello do
  desc "Cleans backend objects (hosts) that are missing in one or more backend systems."
  task :clean_backend_objects => ["dynflow:client", "environment", "check_ping"] do
    User.current = User.anonymous_admin

    print "Cleaning backend objects\n"

    task = ForemanTasks.sync_task(::Actions::Candlepin::Consumer::CleanBackendObjects)

    results = task.output[:results]

    print "\nResults:\n"
    print "Hosts with nil facets: #{results[:hosts_with_nil_facets].length}\n"
    print "Hosts with no subscriptions: #{results[:hosts_with_no_subscriptions].length}\n"
    print "Orphaned consumers: #{results[:orphaned_consumers].length}\n"
    print "Errors: #{results[:errors].length}\n"

    if results[:errors].any?
      print "\nErrors encountered:\n"
      results[:errors].each do |error|
        print "  #{error[:type]}: #{error[:message]}\n"
      end
    end
  end
end
