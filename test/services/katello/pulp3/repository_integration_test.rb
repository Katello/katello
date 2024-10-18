require 'katello_test_helper'
require_relative '../../../support/pulp3_support.rb'

types = Katello::RepositoryTypeManager.defined_repository_types
types.slice!(ENV['TEST_CONTENT_TYPES'].split(',')) unless ENV['CONTENT_TYPES'].blank?
types.values.each do |repository_type|
  if repository_type.test_url
    class_name = "#{repository_type.id.to_s.camelize}TypeSyncTest"
    ::Katello::Pulp3::Repository.const_set(class_name, Class.new(ActiveSupport::TestCase) do
      include Katello::Pulp3Support

      #REPO_TYPE constant is set after class is defined
      def repo_type
        self.class::REPO_TYPE
      end

      def setup
        User.current = users(:admin)
        @primary = SmartProxy.pulp_primary
        @repo = katello_repositories(:fedora_17_x86_64_duplicate)
        @repo.root.update!(url: repo_type.test_url, :content_type => repo_type.id,
                           :download_policy => nil, generic_remote_options: {})
        @repo.root.update(repo_type.test_url_root_options) if repo_type.test_url_root_options
        @repo.update(:pulp_id => @repo.pulp_id + "-test-#{repo_type.id}", :relative_path => "integration_tests/#{repo_type.id}")
        create_repo(@repo, @primary)
        ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, @repo)
      end

      def teardown
        User.as_anonymous_admin do
          ensure_creatable(@repo, @primary)

          Setting[:completed_pulp_task_protection_days] = 0
          DateTime.expects(:now).returns(DateTime.new(3000, 1, 1))
          orphan_cleanup
        end
      end

      def test_sync
        @repo.update(publication_href: nil, version_href: nil)
        ForemanTasks.sync_task(::Actions::Katello::Repository::Sync, @repo)
        @repo.reload

        repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => @repo.root.id,
          :content_view_id => @repo.content_view.id)

        assert_equal repository_reference.repository_href + "versions/1/", @repo.version_href
        refute_nil @repo.version_href
        refute_nil @repo.publication_href unless repo_type.pulp3_skip_publication

        repo_type.content_types.each do |content_type|
          assert @repo.content_counts[content_type.label] > 0
        end
      end

      def test_upload_files
        repo_type.content_types.each do |content_type|
          next unless content_type.test_upload_path

          to_upload = File.join(Katello::Engine.root, content_type.test_upload_path)
          @file = {path: to_upload, filename: File.basename(content_type.test_upload_path)}

          assert_equal 0, @repo.content_counts[content_type.label]
          VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params]) do
            action_result = ForemanTasks.sync_task(::Actions::Katello::Repository::UploadFiles, @repo, [@file], content_type.label)
            assert_equal "success", action_result.result
          end

          assert_equal 1, @repo.reload.content_counts[content_type.label]
        end
      end
    end)

    class_const = Object.const_get("::Katello::Pulp3::Repository::#{repository_type.id.to_s.camelize}TypeSyncTest")
    class_const.const_set('REPO_TYPE', repository_type)
  end
end
