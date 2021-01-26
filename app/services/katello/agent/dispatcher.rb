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

      def self.dispatch(message_type, args)
        message_class = @supported_messages[message_type]

        fail("Unsupported message type") unless message_class

        host_id = args.delete(:host_id)
        fail("No host id provided") unless host_id

        consumer_id = ::Katello::Host::ContentFacet.where(host_id: host_id).pluck(:uuid).first
        fail("No consumer ID for host_id=#{host_id}") unless consumer_id
        args[:consumer_id] = consumer_id

        message = message_class.new(**args)

        history = Katello::Agent::DispatchHistory.new
        history.host_id = host_id
        history.save!

        message.dispatch_history_id = history.id
        message.recipient_address = settings[:client_queue_format] % [consumer_id]
        message.reply_to = settings[:event_queue_name]

        connection = Connection.new
        connection.send_message(message)
        history
      end

      def self.settings
        SETTINGS[:katello][:agent]
      end
    end
  end
end
