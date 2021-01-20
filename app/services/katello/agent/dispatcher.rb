module Katello
  module Agent
    class Dispatcher
      include Katello::Agent::Connection

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

        message = message_class.new(**args)

        history = Katello::Agent::DispatchHistory.new
        history.host_id = args[:host_id]
        history.save!

        message.dispatch_history_id = history.id

        send_message(message)
        history
      end
    end
  end
end
