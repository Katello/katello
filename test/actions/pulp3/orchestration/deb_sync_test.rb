require 'katello_test_helper'

module ::Actions::Pulp3
  class AptSyncTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      User.current = users(:admin)
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:debian_pulp_ragnarok)
      create_repo(@repo, @primary)
      ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, @repo)

      assert_equal 1, Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).count, "Expected a distribution reference."

      @deb_acs = katello_alternate_content_sources(:deb_alternate_content_source)
      @deb_acs.base_url = 'https://fixtures.pulpproject.org/debian/'
      @deb_acs.subpaths = []
      @deb_acs.deb_releases = 'ragnarok'
      @deb_acs.ssl_ca_cert_id = nil
      @deb_acs.ssl_client_cert_id = nil
      @deb_acs.ssl_client_key_id = nil
      @deb_acs.upstream_username = nil
      @deb_acs.upstream_password = nil
      @deb_acs.save!
    end

    def teardown
      @deb_acs.smart_proxy_alternate_content_sources.each do |sma|
        ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Delete, sma)
      end
      @repo.backend_service(@primary).delete_distributions
      @repo.backend_service(@primary).delete_publication
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
      ::Katello::SmartProxyAlternateContentSource.destroy_all
    end

    def test_sync_with_deb_acs
      smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: @deb_acs.id, smart_proxy_id: @primary.id)
      ::Katello::Pulp3::AlternateContentSource.any_instance.stubs(:generate_backend_object_name).returns(@deb_acs.name)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::AlternateContentSource::Refresh, smart_proxy_acs)

      sync_args = { smart_proxy_id: @primary.id, repo_id: @repo.id }
      @repo.update(publication_href: nil, version_href: nil)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
      @repo.reload

      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
        root_repository_id: @repo.root.id,
        content_view_id:    @repo.content_view.id
      )

      assert_equal repository_reference.repository_href + "versions/2/", @repo.version_href
      refute_nil @repo.version_href
      refute_nil @repo.publication_href
    end
  end
end
