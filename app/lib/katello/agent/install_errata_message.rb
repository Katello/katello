module Katello
  module Agent
    class InstallErrataMessage < BaseMessage
      def initialize(errata_ids:, host_id:)
        @errata_ids = errata_ids
        @host_id = host_id
        @content_type = 'erratum'
        @method = 'install'
      end

      protected

      def units
        @errata_ids.map do |id|
          {
            type_id: @content_type,
            unit_key: {
              id: id
            }
          }
        end
      end
    end
  end
end
