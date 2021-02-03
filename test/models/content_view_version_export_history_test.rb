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

    def test_latest_nil_if_no_history
      assert_empty ContentViewVersionExportHistory.latest(@cvv.content_view)
    end

    def test_latest
      content_view = @cvv.content_view
      destination = "greatest"
      path = "/tmp"
      history = ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                        destination_server: destination,
                                                        metadata: {foo: :bar},
                                                        path: path)
      assert_equal history, ContentViewVersionExportHistory.latest(content_view,
                                                                                destination_server: destination)
      assert_nil ContentViewVersionExportHistory.latest(@cvv.content_view)
    end

    def test_invalid_export_type
      destination = "greatest"
      path = "/tmp"
      assert_raises ActiveRecord::RecordInvalid do
        ::Katello::ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                              destination_server: destination,
                                                              metadata: {foo: :bar},
                                                              path: path,
                                                              export_type: "Haha")
      end
    end

    def test_valid_on_blank_export_type
      destination = "greatest"
      path = "/tmp"
      assert_nothing_raised do
        ::Katello::ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                              destination_server: destination,
                                                              metadata: {foo: :bar},
                                                              path: path)
      end
    end

    def test_scoped_search_export_type
      ::Katello::ContentViewVersionExportHistory.destroy_all
      destination = "greatest"
      path = "/tmp"
      assert_empty ContentViewVersionExportHistory.search_for("type = complete")
      ::Katello::ContentViewVersionExportHistory.create!(content_view_version_id: @cvv.id,
                                                            destination_server: destination,
                                                            metadata: {foo: :bar},
                                                            path: path)

      refute_empty ContentViewVersionExportHistory.search_for("type = complete")
    end
  end
end
