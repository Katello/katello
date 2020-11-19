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
                                                                          metadata: {foo: :bar},
                                                                          path: path)
      assert_raises ActiveRecord::RecordInvalid do
        ::Katello::ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                                  destination_server: destination,
                                                                  metadata: {foo: :bar},
                                                                  path: path)
      end

      assert_nothing_raised do
        ::Katello::ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                                destination_server: destination + "foo",
                                                                metadata: {foo: :bar},
                                                                path: path)
      end
    end

    def test_pick_recent_history_nil_if_no_history
      assert_empty ContentViewVersionExportHistory.pick_recent_history(@cvv.content_view)
    end

    def test_pick_recent_history
      content_view = @cvv.content_view
      destination = "greatest"
      path = "/tmp"
      history = ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                        destination_server: destination,
                                                        metadata: {foo: :bar},
                                                        path: path)
      assert_equal history, ContentViewVersionExportHistory.pick_recent_history(content_view,
                                                                                destination_server: destination)
      assert_nil ContentViewVersionExportHistory.pick_recent_history(@cvv.content_view)
    end
  end
end
