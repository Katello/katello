require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  class GluePulpPackageTestBase < ActiveSupport::TestCase
    include RepositorySupport

    @@package_id = nil

    def self.before_suite
      super
      configure_runcible

      VCR.insert_cassette('pulp/content/package')

      RepositorySupport.create_and_sync_repo(@loaded_fixtures['katello_repositories']['fedora_17_x86_64']['id'])

      @@package_id = RepositorySupport.repo.packages.first.id
    end

    def self.after_suite
      run_as_admin do
        RepositorySupport.destroy_repo
        VCR.eject_cassette
      end
    end
  end

  class GluePulpPackageTest < GluePulpPackageTestBase
    def test_find
      package = Package.find(@@package_id)

      refute_nil package
      assert_kind_of Package, package
    end

    def test_nvrea
      package = Package.find(@@package_id)

      refute_nil package.nvrea
    end

    def test_ignored_fields
      refute_includes Package::PULP_SELECT_FIELDS, 'changelog'
      refute_includes Package::PULP_SELECT_FIELDS, 'repodata'
      refute_includes Package::PULP_SELECT_FIELDS, 'filelist'
    end
  end
end
