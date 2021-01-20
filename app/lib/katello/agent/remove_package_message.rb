module Katello
  module Agent
    class RemovePackageMessage < BaseMessage
      def initialize(packages:, host_id:)
        @packages = packages
        @host_id = host_id
        @content_type = 'rpm'
        @method = 'uninstall'
      end

      protected

      def units
        @packages.map do |package|
          nvra = ::Katello::Util::Package.parse_nvrea_nvre(package)
          unit_key = nvra || {
            name: package
          }

          {
            type_id: @content_type,
            unit_key: unit_key
          }
        end
      end
    end
  end
end
