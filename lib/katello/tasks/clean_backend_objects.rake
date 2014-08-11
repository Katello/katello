namespace :katello do
  desc "Cleans backend objects (systems) that are missing in one or more backend systems"
  task :clean_backend_objects => ["environment"] do
    User.current = User.anonymous_admin
    Katello::System.find_each do |system|
      cp_fail = false
      pulp_fail = false
      begin
        system.facts 
      rescue  RestClient::ResourceNotFound => e
        cp_fail = true
      rescue  RestClient::Gone => e
        cp_fail = true
      end

      begin
        system.pulp_facts
      rescue  RestClient::ResourceNotFound => e
        pulp_fail = true
      rescue  RestClient::Gone => e
        pulp_fail = true
      rescue  RestClient::Conflict => e
        pulp_fail = true
      end

      if cp_fail || pulp_fail
        print "System #{system.id} #{system.name} #{system.uuid} is partially missing.  Cleaning.\n"
        system.del_candlepin_consumer unless cp_fail        
        system.del_pulp_consumer unless pulp_fail
        Katello::System.index.remove system
        system.system_activation_keys.destroy_all
        system.delete
      end      
    end
  end
end
