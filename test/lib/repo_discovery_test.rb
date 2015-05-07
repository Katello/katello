require 'katello_test_helper'

module Katello
  class FileRepoDiscoveryTest < ActiveSupport::TestCase
    def test_run
      base_url = "file://#{Katello::Engine.root}/test/fixtures/"

      rd = RepoDiscovery.new(base_url)
      found = []
      add_proc = lambda { |url| found << url }
      continue_proc = lambda { true }

      found_final = rd.run(add_proc, continue_proc)
      assert_equal found, found_final  #validate that final list equals incremental list
      assert_equal 1, found.size
      assert_equal found.first, base_url + 'test_repos/zoo'
    end
  end
end
