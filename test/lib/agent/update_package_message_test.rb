require 'katello_test_helper'

module Katello
  module Agent
    class UpdatePackageMessageTest < ActiveSupport::TestCase
      def test_all_package_update
        json = UpdatePackageMessage.new(content: [], consumer_id: "100000").json
        assert json[:request][:args][1][:all]
        assert_empty json[:request][:args][0][0][:unit_key]
      end

      def test_content_package_update
        json = UpdatePackageMessage.new(content: ["foo.rpm"], consumer_id: "100000").json
        assert_nil json[:request][:args][1][:all]
        assert_equal "foo.rpm", json[:request][:args][0][0][:unit_key][:name]
      end
    end
  end
end
