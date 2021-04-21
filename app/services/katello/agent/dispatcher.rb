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

      def self.dispatch(message_type, histories, args)
        message_class = @supported_messages[message_type]
        fail("Unsupported message type: #{message_type}") unless message_class

        messages = histories.map do |history|
          message = message_class.new(**args.merge(consumer_id: history.host.subscription_facet.uuid))
          message.dispatch_history_id = history.id
          message.recipient_address = settings[:client_queue_format] % history.host.subscription_facet.uuid
          message.reply_to = settings[:event_queue_name]
          message
        end

        connection = Connection.new
        connection.send_messages(messages)

        histories
      end

      def self.create_histories(host_ids:)
        histories = host_ids.map do |id|
          Katello::Agent::DispatchHistory.new(host_id: id)
        end

        Katello::Agent::DispatchHistory.import(histories)

        histories
      end

      def self.delete_client_queue(queue_name:)
        connection = Connection.new
        connection.delete_client_queue(queue_name)
      end

      def self.host_queue_name(host)
        uuid = host.content_facet.uuid
        settings[:client_queue_format] % uuid
      end

      def self.settings
        SETTINGS[:katello][:agent]
      end
    end
  end
end
