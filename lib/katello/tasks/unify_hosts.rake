namespace :katello do
  desc "Unify hosts that have registered with both fqdn and shortname.\
        Run with HOSTS=foobar.example.com,foobar to run for specific hosts."
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
      ::Host.unscoped.where("name like '%.%'").find_each do |host|
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
      #first look based off mac address
      mac = host.primary_interface.try(:mac)
      if mac.blank?
        puts "Skipping #{host.name} due to blank primary interface mac\n"
        return
      end

      possible_match = Nic::Base.where("host_id != #{host.id}").where(:mac => mac).first.try(:host)
      if possible_match && host.name.starts_with?(possible_match.name)
        possible_match
      end
    end

    def unify(fqdn_host, short_host)
      if fqdn_host.subscription_facet.try(:uuid).nil? && fqdn_host.content_facet.try(:uuid).nil?
        puts "Unifying #{fqdn_host.name} with #{short_host.name}\n"
        fqdn_host.subscription_facet.try(:destroy!)
        fqdn_host.content_facet.try(:destroy!)

        content_facet = short_host.content_facet
        sub_facet = short_host.subscription_facet

        if content_facet
          content_facet.host = fqdn_host
          content_facet.save!
          content_facet.update_errata_status
        end

        if sub_facet
          sub_facet.host = fqdn_host
          sub_facet.save!
          sub_facet.update_subscription_status
        end

        unify_arf_reports(fqdn_host, short_host)
        short_host.reload.destroy!
      else
        puts "#{fqdn_host.name} has a registered consumer, skipping"
      end
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
