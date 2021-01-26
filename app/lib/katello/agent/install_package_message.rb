module Katello
  module Agent
    class InstallPackageMessage < BaseMessage
      def initialize(packages:, consumer_id:)
        @packages = packages
        @consumer_id = consumer_id
        @content_type = 'rpm'
        @method = 'install'
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
