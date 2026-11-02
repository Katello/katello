require 'katello_test_helper'

module ::Actions::Pulp3::Orchestration::Repository
  class GenerateMetadataRunTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:action_class) { ::Actions::Pulp3::Orchestration::Repository::GenerateMetadata }
    let(:action) { create_action action_class }
    let(:source_repo) { katello_repositories(:generic_file) }
    let(:target_repo) { katello_repositories(:generic_file_dev) }
    let(:smart_proxy) { SmartProxy.pulp_primary }

    before do
      source_repo.update!(:version_href => '/pulp/api/v3/repositories/file/file/abc/versions/1/',
                          :version_prn => 'prn:file:abc:1')
      @index = ::Katello::ContentIndex.create!(:version_href => source_repo.version_href)
      action.input.update(:target_repository_id => target_repo.id, :source_repository_id => source_repo.id,
                          :smart_proxy_id => smart_proxy.id)
    end

    it 'takes over the source version when asked to reuse it' do
      action.input.update(:reuse_version => true)

      action.run

      target_repo.reload
      assert_equal source_repo.version_href, target_repo.version_href
      assert_equal source_repo.version_prn, target_repo.version_prn
      assert_equal @index.id, target_repo.content_index_id
    end

    it 'keeps the target version when not asked to reuse it' do
      target_repo.update!(:version_href => '/pulp/api/v3/repositories/file/file/def/versions/2/')

      action.run

      assert_equal '/pulp/api/v3/repositories/file/file/def/versions/2/', target_repo.reload.version_href
    end
  end
end
