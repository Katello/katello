module Katello
  module Agent
    class InstallErrataMessage < BaseMessage
      def initialize(content:, consumer_id:)
        @errata_ids = content
        @consumer_id = consumer_id
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
