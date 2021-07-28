module Katello
  module Agent
    class UpdatePackageMessage < BaseMessage
      def initialize(content:, consumer_id:)
        @packages = content
        @consumer_id = consumer_id
        @content_type = 'rpm'
        @method = 'update'
      end

      protected

      def options
        ops = super
        ops[:all] = true if @packages.blank?
        ops
      end

      def units
        return [{ type_id: @content_type, unit_key: {}}] if @packages.blank?

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
