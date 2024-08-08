module Katello
  module Concerns
    module SmartProxyHelperExtensions
      def disks(storage)
        storage.map do |values|
          values['header'] = values['description']
          values['available_percent'] = 100 - values['percentage']
          values['size_status'] = storage_warning(values['free'])
          values
        end
      end

      def humanize_bytes(bytes)
        mb = bytes / 1024 / 1024
        if mb < 1000
          "#{mb} MB"
        else
          "#{mb / 1024} GB"
        end
      end

      def boolean_to_icon(boolean)
        boolean = ::Foreman::Cast.to_bool(boolean)
        icon = boolean ? 'ok' : 'error-circle-o'
        icon_text(icon, '', :kind => 'pficon')
      end

      def download_policies
        policies = [
          {
            :name => _("On Demand"),
            :label => ::Katello::RootRepository::DOWNLOAD_ON_DEMAND,
          },
          {
            :name => _("Immediate"),
            :label => ::Katello::RootRepository::DOWNLOAD_IMMEDIATE,
          },
          {
            :name => _("Streamed"),
            :label => SmartProxy::DOWNLOAD_STREAMED,
          },
          {
            :name => _("Inherit from Repository"),
            :label => SmartProxy::DOWNLOAD_INHERIT,
          },
        ]

        policies.map { |p| OpenStruct.new(p) }
      end

      def storage_warning(available)
        gb_size = available.to_i / 1_073_741_824
        case gb_size
        when 0..1
          "danger"
        when 2..10
          "warning"
        else
          "success"
        end
      end

      def kb_to_actual(number)
        # Convert number from kb to mb to any size
        number_to_human_size(number.to_i * 1024)
      end
    end
  end
end
