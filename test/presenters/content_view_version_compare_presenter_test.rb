require 'katello_test_helper'

module Katello
  class ContentViewVersionComparePresenterTest < ActiveSupport::TestCase
    def setup
      @complete_version = katello_content_view_versions(:library_default_version)
      @incomplete_version = katello_content_view_versions(:library_view_version_1)
      @versions = [@complete_version, @incomplete_version]

      @complete_erratum = katello_errata(:security)
      @incomplete_erratum = katello_errata(:bugfix)

      @fedora_repo = katello_repositories(:fedora_17_x86_64)
    end

    test "both views match" do
      present = ContentViewVersionComparePresenter.new(@complete_erratum, @versions, nil)
      assert_includes present.comparison, @complete_version.id
      assert_includes present.comparison, @incomplete_version.id
      assert_equal 2, present.comparison.size
    end

    test "only one view matches" do
      present = ContentViewVersionComparePresenter.new(@incomplete_erratum, @versions, nil)
      assert_includes present.comparison, @complete_version.id
      refute_includes present.comparison, @incomplete_version.id
      assert_equal 1, present.comparison.size
    end

    test "only one view matches with specified repo" do
      present = ContentViewVersionComparePresenter.new(@complete_version, @versions, @fedora_repo)
      assert_includes present.comparison, @complete_version.id
      refute_includes present.comparison, @incomplete_version.id
      assert_equal 1, present.comparison.size
    end
  end
end
