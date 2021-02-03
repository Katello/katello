module Katello
  module Agent
    class Dispatcher
      @supported_messages = {}

      def self.register_message(name, klass)
        @supported_messages[name] = klass
      end

      register_message(:install_package, Katello::Agent::InstallPackageMessage)
      register_message(:remove_package, Katello::Agent::RemovePackageMessage)
      register_message(:update_package, Katello::Agent::UpdatePackageMessage)
      register_message(:install_errata, Katello::Agent::InstallErrataMessage)
      register_message(:install_package_group, Katello::Agent::InstallPackageGroupMessage)
      register_message(:remove_package_group, Katello::Agent::RemovePackageGroupMessage)

      def self.dispatch(message_type, host_ids, args)
        message_class = @supported_messages[message_type]

        fail("Unsupported message type") unless message_class

        uuid_data = ::Katello::Host::ContentFacet.where(host_id: host_ids).pluck(:host_id, :uuid)
        fail("Couldn't find all hosts specified") unless host_ids.size == uuid_data.size

        host_data = uuid_data.map do |host_id, consumer_id|
          {
            host_id: host_id,
            consumer_id: consumer_id,
            history: Katello::Agent::DispatchHistory.new(host_id: host_id),
            message: message_class.new(**args.merge(consumer_id: consumer_id))
          }
        end

        histories = host_data.map { |attrs| attrs[:history] }
        ActiveRecord::Base.transaction do
          Katello::Agent::DispatchHistory.import(histories)

          host_data.each do |d|
            d[:message].dispatch_history_id = d[:history].id
            d[:message].recipient_address = settings[:client_queue_format] % [d[:consumer_id]]
            d[:message].reply_to = settings[:event_queue_name]
          end

          connection = Connection.new
          connection.send_messages(host_data.map { |d| d[:message] })
        end

        histories
      end

      def self.settings
        SETTINGS[:katello][:agent]
      end
    end
  end
end
