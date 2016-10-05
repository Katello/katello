module Katello
  module Concerns
    module SmartProxyHelperExtensions
      def disks(storage)
        mount_points = {}
        disks = []
        storage.each do |_name, values|
          mount = values['mounted']
          mount_points[mount].nil? ? mount_points[mount] = [values['path']] : mount_points[mount] << values['path']
          values['header'] = "#{mount_points[mount].to_sentence} (on #{values['filesystem']})"
          values['available_percent'] = available_percent(values['percent'])
          values['size_status'] = storage_warning(values['available'])
          values['total'] = kb_to_actual(values.delete('1k-blocks'))
          values['used'] = kb_to_actual(values['used'])
          values['available'] = kb_to_actual(values['available'])
          disks << values
        end
        disks.group_by { |h| h['mounted'] }.map { |_, hs| hs.reduce(:merge) }
      end

      def boolean_to_icon(boolean)
        boolean = ::Foreman::Cast.to_bool(boolean)
        icon = boolean ? 'ok' : 'error-circle-o'
        icon_text(icon, '', :kind => 'pficon')
      end

      def available_percent(percent_string)
        used_percent = percent_string.delete('%').to_i
        available_percent = 100 - used_percent
        "#{available_percent}%"
      end

      def download_policies
        policies = [
          {
            :name => _("On Demand"),
            :label => ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND
          },
          {
            :name => _("Background"),
            :label => ::Runcible::Models::YumImporter::DOWNLOAD_BACKGROUND
          },
          {
            :name => _("Immediate"),
            :label => ::Runcible::Models::YumImporter::DOWNLOAD_IMMEDIATE
          },
          {
            :name => _("Inherit from Repository"),
            :label => SmartProxy::DOWNLOAD_INHERIT
          }
        ]

        policies.map { |p| OpenStruct.new(p) }
      end

      def storage_warning(available)
        gb_size = available.to_i / 1_048_576
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
