module Katello
  module Agent
    class UpdatePackageMessage < BaseMessage
      def initialize(packages:, host_id:)
        @packages = packages
        @host_id = host_id
        @content_type = 'rpm'
        @method = 'update'
      end

      protected

      def units
        @packages.map do |package|
          {
            type_id: @content_type,
            unit_key: {
              name: package
            }
          }
        end
      end
    end
  end
end
