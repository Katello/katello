#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
  class ContentVIewVersionComparePresenterTest < ActiveSupport::TestCase
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
