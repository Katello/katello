require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
  class RepositoryGroup < VCRTestBase
    let(:repo) { katello_repositories(:fedora_17_x86_64) }

    def setup
      super
      # the runcible repo group distributor uses a random ID when POSTing, we
      # need to be more lenient on VCR matches
      VCR.eject_cassette
      VCR.insert_cassette('actions/pulp/repository/repository_group/create_export_delete',
                          :match_requests_on => [:path, :method])
    end

    def teardown
      super
      VCR.eject_cassette
    end

    def test_create_export_delete
      run_action(::Actions::Pulp::RepositoryGroup::Create,
                  id: "fake-repo-group",
                  pulp_ids: [repo.pulp_id])
      run_action(::Actions::Pulp::RepositoryGroup::Export,
                  id: "fake-repo-group",
                  export_to_iso: false,
                  export_directory: "/tmp/katello-repo-exports/foo")
      run_action(::Actions::Pulp::RepositoryGroup::Delete,
                  id: "fake-repo-group")
    end
  end
end
