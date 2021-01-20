module Katello
  module Agent
    class InstallPackageGroupMessage < BaseMessage
      def initialize(groups:, host_id:)
        @groups = groups
        @host_id = host_id
        @content_type = 'package_group'
        @method = 'install'
      end

      protected

      def units
        @groups.map do |group|
          {
            type_id: @content_type,
            unit_key: {
              name: group
            }
          }
        end
      end
    end
  end
end
