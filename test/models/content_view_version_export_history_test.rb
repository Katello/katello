require 'katello_test_helper'

module Katello
  class ContentViewVersionExportHistoryTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @cvv = create(:katello_content_view_version, :major => 1, :minor => 0)
    end

    def test_create_duplicate
      destination = "greatest"
      path = "/tmp"
      ::Katello::ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                                          destination_server: destination,
                                                                          path: path)
      assert_raises ActiveRecord::RecordInvalid do
        ::Katello::ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                                  destination_server: destination,
                                                                  path: path)
      end

      assert_nothing_raised do
        ::Katello::ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                                destination_server: destination + "foo",
                                                                path: path)
      end
    end
  end
end
