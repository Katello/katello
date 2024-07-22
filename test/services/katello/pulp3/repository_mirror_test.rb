require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class TestRepositoryService
      end

      class RepositoryMirrorTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @repo_service = TestRepositoryService.new
          @repo_mirror = ::Katello::Pulp3::RepositoryMirror.new(@repo_service)
          @repo_mirror.stubs(:common_remote_options).returns({:name => 'some_repo'})
          @repo_mirror.stubs(:remote_feed_url).returns('/a/path/to/content')
        end

        def test_remote_options_with_mirror_remote_options
          @repo_service.stubs(:mirror_remote_options).returns({:mirror_remote_option1 => 'an option'})
          expected_options = {
            :name => "some_repo",
            :url => "/a/path/to/content",
            :mirror_remote_option1 => "an option",
          }
          assert_equal expected_options, @repo_mirror.remote_options
        end

        def test_remote_options_without_mirror_options
          @repo_mirror.stubs(:common_remote_options).returns({:name => 'some_repo'})
          @repo_mirror.stubs(:remote_feed_url).returns('/a/path/to/content')
          expected_options = {
            :name => "some_repo",
            :url => "/a/path/to/content",
          }
          assert_equal expected_options, @repo_mirror.remote_options
        end
      end
    end
  end
end
