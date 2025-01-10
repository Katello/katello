module Katello
  module Concerns
    module BookmarkControllerValidatorExtensions
      extend ActiveSupport::Concern

      def valid_controllers_list
        @valid_controllers_list ||= (["dashboard", "common_parameters", "/katello/api/v2/host_bootc_images"] +
          ActiveRecord::Base.connection.tables.map(&:to_s) +
          Permission.resources.map(&:tableize)).uniq
      end
    end
  end
end
