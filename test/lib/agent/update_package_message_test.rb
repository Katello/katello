require 'katello_test_helper'

module Katello
  module Agent
    class UpdatePackageMessageTest < ActiveSupport::TestCase
      def test_all_package_update
        json = UpdatePackageMessage.new(content: [], consumer_id: "100000").json
        options = json[:request][:args][1]
        units = json[:request][:args][0]
        assert options[:all]
        assert_empty units[0][:unit_key]
      end

      def test_content_package_update
        json = UpdatePackageMessage.new(content: ["foo.rpm"], consumer_id: "100000").json
        options = json[:request][:args][1]
        units = json[:request][:args][0]

        assert_nil options[:all]
        assert_equal "foo.rpm", units[0][:unit_key][:name]
      end
    end
  end
end
