namespace :katello do
  task :preupgrade_content_host_check => ["environment"] do
    desc "Task that can be run before upgrading to Katello 3.0 to show a list of registered Content Hosts that will be deleted."

    ping = ::Katello::Ping.ping
    if ping[:status] != ::Katello::Ping::OK_RETURN_CODE
      fail _("Some backend services are not running: %s") % ping.inspect
    end

    puts "Calculating Host changes on upgrade.  This may take a few minutes."

    User.current = User.anonymous_api_admin
    @systems_to_unregister = {}

    def ensure_one_system_per_hostname(systems)
      systems = get_systems_with_facts(systems)
      system_hostnames = group_systems_by_hostname(systems)

      system_hostnames.each do |hostname, duplicate_systems|
        if duplicate_systems.count > 1
          unregister_all_but_last_system(duplicate_systems)
        end
      end
    end

    def group_systems_by_hostname(systems)
      system_hostnames = {}

      systems.each do |system|
        hostname = system.facts['network.hostname']
        if system_hostnames[hostname]
          system_hostnames[hostname].push(system)
        else
          system_hostnames[hostname] = [system]
        end
      end

      system_hostnames
    end

    def get_systems_with_facts(systems)
      systems_to_remove = []

      systems.each do |system|
        begin
          facts = system.facts
          unless facts
            systems_to_remove.push(system)
          end
        rescue RestClient::Exception
          systems_to_remove.push(system)
        end
      end

      systems_to_remove.each do |system|
        systems.delete(system)
        unregister_system(system, "This Content Host seems to be missing from the backend service Candlepin.")
      end

      systems
    end

    def unregister_all_but_last_system(systems)
      systems_by_created_date = systems.sort_by(&:created_at)
      system = systems_by_created_date.pop

      systems_by_created_date.each do |system_to_remove|
        unregister_system(system_to_remove, "More recently registered Content Host with same hostname #{system.hostname} found.")
      end

      system
    end

    def unregister_system(system, cause)
      @systems_to_unregister[system] ||= []
      @systems_to_unregister[system] << cause
    end

    def human_output(systems)
      puts "\n\nSummary:\n"
      puts "Content hosts to be preserved: #{::Katello::System.count - systems.count}"
      puts "Content hosts to be deleted: #{systems.count}"
    end

    def csv_output(systems)
      header = 'uuid, name, hostname, last_checkin, causes for deletion'
      ouptut_lines = systems.map do |system, causes|
        "#{system.uuid},#{system.name},#{system.hostname},#{system.lastCheckin},#{causes.join("  ")}"
      end
      "#{header}\n#{ouptut_lines.join("\n")}"
    end

    def write_csv(systems)
      filename = "/tmp/pre-upgrade-#{Time.new.to_i}.csv"
      file = open(filename, 'w')
      file.write(csv_output(systems))
      file.close
      filename
    end

    ensure_one_system_per_hostname(Katello::System.all)
    systems = get_systems_with_facts(Katello::System.all)

    systems.each do |system|
      next if @systems_to_unregister.include?(system)
      hostname = system.facts['network.hostname']

      if hostname.nil?
        unregister_system(system, "Missing hostname information.")
        break
      end

      hosts = ::Host.where(:name => hostname)
      if hosts.any? && hosts.where(:organization_id => system.environment.organization.id).empty? # host is not in the correct org
        unregister_system(system, "Organization mismatch between Host (#{hosts[0].org.name}) and Content Host #{system.environment.organization.name}.")
      end
    end

    if @systems_to_unregister.any?
      human_output(@systems_to_unregister)
      puts "Details on Content Hosts planned for deletion saved to #{write_csv(@systems_to_unregister)}"
      puts "You may want to manually resolve some of the conflicts and duplicate Content Hosts."
      puts "Upon upgrade those found for deletion will be removed permanently."
    else
      puts "Upgrading will not affect any of your Content Hosts."
    end
  end
end
