namespace :katello do
  namespace :upgrades do
    namespace '4.12' do
      desc "Update content access modes for all organizations"
      task :update_content_access_modes, [:commit] => ["environment"] do |_t, args|
        # make sure Candlepin is running
        print "Checking Candlepin status\n"
        Katello::Ping.ping!(services: [:candlepin])

        # To run without committing changes, use:
        # foreman-rake katello:upgrades:4.12:update_content_access_modes[dry_run]
        commit = !(args[:commit].to_s == 'dry_run')
        msg_word = commit ? "Setting" : "Checking"
        print "#{msg_word} content access modes\n"
        migrated_orgs_count = 0
        Organization.all.each do |org|
          next if org.simple_content_access?

          print "#{msg_word} content access mode for #{org.name}\n"
          migrated_orgs_count += 1
          if commit
            ::Katello::Resources::Candlepin::Owner.update(org.label, contentAccessMode: 'org_environment')
          end
        end
        print "----------------------------------------\n"
        if commit
          print "Set content access mode for #{migrated_orgs_count} organizations\n"
        else
          print "#{migrated_orgs_count} organizations would be migrated to Simple Content Access on upgrade\n"
        end
        print "----------------------------------------\n"
      end
    end
  end
end
