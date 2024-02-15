namespace :katello do
  desc "Unify hosts that have registered with both fqdn and shortname.\
        Run with HOSTS=foobar.example.com,foobar to run for specific hosts.\
        Run with USE_NAME=true to match purely by name and not by mac address.
        Run with DRYRUN=true to not modify anything."
  task :unify_hosts => :environment do
    def main
      hostnames = ENV['HOSTS'].try(:split, ',')
      if hostnames.blank?
        unify_all
      elsif hostnames.count == 2
        unify_two(hostnames[0], hostnames[1])
      else
        puts "HOSTS specified but did not receive two. Usage: HOSTS=foobar.example.com,foobar"
      end
    end

    def unify_all
      passed = []
      ::Host.unscoped.where("name like '%.%'").find_each do |host|
        next if passed.include?(host.name.downcase)

        passed << host.name.downcase
        puts "Skipping #{host.name}, more than one record." && next if ::Host.unscoped.where(:name => host.name).count > 1

        short_host = find_match(host)
        unify(host, short_host) if short_host
      end
    end

    def unify_two(name1, name2)
      fail _("#{name1} specified twice") if name1 == name2

      host1 = Host.find_by(:name => name1)
      host2 = Host.find_by(:name => name2)
      if host1.nil? || host2.nil?
        puts "Could not find both hosts #{host1} and #{host2}\n"
      elsif name1.starts_with?(name2)
        unify(host1, host2)
      elsif name2.starts_with?(name1)
        unify(host2, host1)
      else
        puts "#{host1} and #{host2} do not share a host shortname\n"
      end
    end

    def find_match(host)
      use_name = ENV['USE_NAME'].try(:downcase) == 'true'
      if use_name
        find_match_by_name(host)
      else
        find_match_by_mac(host)
      end
    end

    def find_match_by_name(host)
      short = host.name.split('.')[0]
      hosts = ::Host.where("name like '#{short}' or name ilike '#{host.name}'").where("id != #{host.id}").where("name != '#{host.name}'")

      if hosts.count > 1
        puts "Found multiple name matches for #{host.name}; skipping: #{hosts.pluck(:name).join(', ')}"
        nil
      else
        hosts.first
      end
    end

    def find_match_by_mac(host)
      #first look based off mac address
      mac = host.primary_interface.try(:mac)
      if mac.blank?
        puts "Skipping #{host.name} due to blank primary interface mac\n"
        return
      end

      possible_matches = Nic::Base.where("host_id != #{host.id}").where(:mac => mac)
      possible_match = possible_matches.find { |nic| host.name.downcase.starts_with?(nic.host.name.downcase) }
      possible_match.try(:host)
    end

    def registered?(host)
      host.subscription_facet.try(:uuid)
    end

    #returns [provisioning_host, facet_host]
    def pick_hosts(host_one, host_two)
      if registered?(host_one) && registered?(host_two)
        puts "Both #{host_one.name} and #{host_two.name} are registered, skipping."
        nil
      elsif !registered?(host_one) && registered?(host_two)
        [host_one, host_two]
      elsif registered?(host_one) && !registered?(host_two)
        [host_two, host_one]
      else
        puts "Neither #{host_one.name} nor #{host_two.name} are registered, skipping."
        nil
      end
    end

    def unify(host_one, host_two)
      provisioning_host, facet_host = pick_hosts(host_one, host_two)
      return if provisioning_host.nil? || facet_host.nil?

      if facet_host.compute_resource
        puts "Host #{facet_host.name} is registered with subscription-manager but is assigned to a compute resource, please un-assign this host first."
        return
      end

      if facet_host.managed?
        puts "Host #{facet_host.name} is registered with subscription-manager but is managed, please un-manage this host first."
        return
      end

      puts "Unifying #{provisioning_host.name} with #{facet_host.name}\n"
      return if ENV['DRYRUN']

      provisioning_host.subscription_facet.try(:destroy!)
      provisioning_host.content_facet.try(:destroy!)

      content_facet = facet_host.content_facet
      sub_facet = facet_host.subscription_facet

      if content_facet
        content_facet.host = provisioning_host
        provisioning_host.content_facet = content_facet
        content_facet.save!
        content_facet.update_errata_status
      end

      if sub_facet
        sub_facet.host = provisioning_host
        sub_facet.save!
      end

      provisioning_host.name = provisioning_host.name.downcase
      unify_arf_reports(provisioning_host, facet_host)
      facet_host.reload.destroy!
    end

    def unify_arf_reports(fqdn_host, short_host)
      if short_host.try(:arf_reports)
        short_host.arf_reports.each do |report|
          report.host = fqdn_host
          report.save!
        end
      end
    end

    main
  end
end
