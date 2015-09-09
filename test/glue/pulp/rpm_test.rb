require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  class GluePulpRpmTestBase < ActiveSupport::TestCase
    include RepositorySupport

    @@package_id = nil

    def self.before_suite
      configure_runcible
      VCR.insert_cassette('pulp/content/rpm')
    end

    def self.after_suite
      VCR.eject_cassette
    end

    def setup
      User.current = users(:admin)
      repo = Repository.find(@loaded_fixtures['katello_repositories']['fedora_17_x86_64']['id'])
      RepositorySupport.create_and_sync_repo(repo.id)
      repo.index_db_rpms
      @package_id = RepositorySupport.repo.rpms.first.id
    end

    def teardown
      RepositorySupport.destroy_repo
      User.current = nil
    end
  end

  class GluePulpRpmTest < GluePulpRpmTestBase
    def test_find
      package = Rpm.find(@package_id)

      refute_nil package
      refute_empty package.backend_data
    end

    def test_requires
      package = Rpm.find(@package_id)

      refute_empty package.requires
      refute_empty package.provides
    end

    def test_ignored_fields
      refute_includes Rpm::PULP_SELECT_FIELDS, 'changelog'
      refute_includes Rpm::PULP_SELECT_FIELDS, 'repodata'
      refute_includes Rpm::PULP_SELECT_FIELDS, 'filelist'
    end
  end
end
