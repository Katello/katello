require 'katello_test_helper'

module Katello
  class ContentViewRepositoryTest < ActiveSupport::TestCase
    def setup
    end

    def test_import_only_yum_repos
      cv = katello_content_views(:import_only_view)

      cv.repositories << katello_repositories(:rhel_6_x86_64)

      assert cv.valid?
    end

    def test_import_only_non_yum_repos
      cv = katello_content_views(:import_only_view)

      assert_raises(ActiveRecord::RecordInvalid) do
        cv.repositories << katello_repositories(:busybox)
      end
    end
  end
end
