require 'katello_test_helper'

module Katello
  class ContentViewVersionImportHistoryTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @cvv = create(:katello_content_view_version, :major => 1, :minor => 0)
    end

    def test_valid_on_blank_import_type
      path = "/tmp"
      assert_nothing_raised do
        ContentViewVersionImportHistory.create!(content_view_version_id: @cvv.id,
                                                  metadata: {foo: :bar},
                                                  path: path)
      end
      assert_equal ContentViewVersionImportHistory.last.import_type, "complete"
    end

    def test_valid_on_import_type_from_metadata
      path = "/tmp"
      assert_nothing_raised do
        ContentViewVersionImportHistory.create!(content_view_version_id: @cvv.id,
                                                  metadata: { incremental: true },
                                                  path: path)
      end
      assert_equal ContentViewVersionImportHistory.last.import_type, "incremental"
    end

    def test_scoped_search_import_type
      path = "/tmp"
      assert_empty ContentViewVersionImportHistory.search_for("type = complete")
      ::Katello::ContentViewVersionImportHistory.create!(content_view_version_id: @cvv.id,
                                                            metadata: {foo: :bar},
                                                            path: path)

      refute_empty ContentViewVersionImportHistory.search_for("type = complete")
    end
  end
end
