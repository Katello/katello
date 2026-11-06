require 'katello_test_helper'

# CloneToVersion points an unfiltered clone at its source's version and publication instead of copying.
# Incremental updates rely on this for repos that receive no new content.
module ::Actions::Pulp3
  class ReuseSourceVersionTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:source_repo) { katello_repositories(:fedora_17_x86_64) }
    let(:target_repo) { katello_repositories(:fedora_17_x86_64_dev) }
    let(:smart_proxy) { SmartProxy.pulp_primary }

    def test_copy_all_units_reuses_source_version
      source_repo.update!(version_href: '/pulp/api/v3/repositories/rpm/rpm/source/versions/3/', version_prn: 'prn:rpm.rpmrepositoryversion:source3')
      target_repo.update!(version_href: nil, version_prn: nil)

      action = create_action(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits)
      planned = plan_action(action, target_repo, smart_proxy, [source_repo])
      run_action(planned)

      assert_equal source_repo.version_href, target_repo.reload.version_href
      assert_equal source_repo.version_prn, target_repo.version_prn
      refute_action_planned(action, ::Actions::Pulp3::Repository::CopyContent)
      refute_action_planned(action, ::Actions::Pulp3::Repository::CopyVersion)
    end

    def test_generate_metadata_reuses_source_publication
      source_repo.update!(publication_href: '/pulp/api/v3/publications/rpm/rpm/source/', publication_prn: 'prn:rpm.rpmpublication:source')
      target_repo.update!(publication_href: nil, publication_prn: nil)

      action = create_action(::Actions::Pulp3::Orchestration::Repository::GenerateMetadata)
      planned = plan_action(action, target_repo, smart_proxy, source_repository: source_repo)
      run_action(planned)

      assert_equal source_repo.publication_href, target_repo.reload.publication_href
      assert_equal source_repo.publication_prn, target_repo.publication_prn
      refute_action_planned(action, ::Actions::Pulp3::Repository::CreatePublication)
    end
  end
end
