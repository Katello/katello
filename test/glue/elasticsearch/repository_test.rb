require 'katello_test_helper'

module Katello
  class RepositoryTest < ActiveSupport::TestCase
    def setup
      Package.stubs(:create_index)

      cv = ContentView.new
      cv.stubs(:default?).returns(false)

      @repo = Repository.new(:pulp_id => "abcrepo")
      @repo.stubs(:content_view).returns(cv)
    end

    def test_index_packages
      @repo.stubs(:package_ids).returns([1, 2, 3])
      @repo.stubs(:indexed_package_ids).returns([1, 2, 5])
      Package.expects(:add_indexed_repoid).once.with([3], 'abcrepo')
      Package.expects(:remove_indexed_repoid).once.with([5], 'abcrepo')
      @repo.index_packages
    end
  end
end
