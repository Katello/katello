namespace :katello do
  desc "Cleans backend objects (systems) that are missing in one or more backend systems"
  task :clean_backend_objects => ["environment"] do
    def cleanup_systems
      Katello::System.find_each do |system|

        if system.uuid.nil?
          cp_fail = true
          pulp_fail = true
        else
          cp_fail = test_method { system.facts }
          pulp_fail = test_method { system.pulp_facts } unless system.is_a?(Katello::Hypervisor)
        end

        if cp_fail || pulp_fail
          print "System #{system.id} #{system.name} #{system.uuid} is partially missing.  Cleaning.\n"
          ::Katello::Resources::Candlepin::Consumer.destroy(system.uuid) unless cp_fail
          system.del_pulp_consumer unless (pulp_fail || system.is_a?(Katello::Hypervisor))
          system.destroy!
        end
      end
    end

    def test_method
      yield
      false
    rescue RestClient::ResourceNotFound => e
      true
    rescue RestClient::Gone => e
      true
    rescue RestClient::Conflict => e
      true
    end

    def cleanup_host_delete_artifacts
      # clean up dirty consumer data in candleplin,
      # that did not get cleared by host delete.
      # look at https://bugzilla.redhat.com/show_bug.cgi?id=1140653
      # for more information
      cp_consumers = ::Katello::Resources::Candlepin::Consumer.get({})
      cp_consumers.reject! { |consumer| consumer['type']['label'] == 'uebercert' }
      cp_consumer_ids = cp_consumers.map {|cons| cons["uuid"]}
      katello_consumer_ids = ::Katello::System.pluck(:uuid)
      deletable_ids = cp_consumer_ids - katello_consumer_ids
      deletable_ids.each do |consumer_id|
        begin
          Katello::Resources::Candlepin::Consumer.destroy(consumer_id)
        rescue RestClient::Exception => e
          p "exception when destroying candlepin consumer #{consumer_id}:#{e.inspect}"
        end
        begin
          Katello.pulp_server.extensions.consumer.delete(consumer_id)
        rescue RestClient::ResourceNotFound => e
          #do nothing
        rescue RestClient::Exception => e
          p "exception when destroying pulp consumer #{consumer_id}:#{e.inspect}"
        end
      end
    end

    User.current = User.anonymous_admin
    cleanup_systems
    cleanup_host_delete_artifacts
  end
end
