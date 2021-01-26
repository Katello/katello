module Katello
  module Agent
    class RemovePackageGroupMessage < BaseMessage
      def initialize(groups:, consumer_id:)
        @groups = groups
        @consumer_id = consumer_id
        @content_type = 'package_group'
        @method = 'uninstall'
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
