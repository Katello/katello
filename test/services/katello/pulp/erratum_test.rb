require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Service
    class ErratumTestBase < ActiveSupport::TestCase
      include RepositorySupport

      @@package_id = nil

      def setup
        User.current = User.find(FIXTURES['users']['admin']['id'])

        VCR.insert_cassette('services/pulp/erratum')

        RepositorySupport.create_and_sync_repo(FIXTURES['katello_repositories']['fedora_17_x86_64']['id'])

        @@full_errata_id = 'RHSA-2010:0858'
      end

      def teardown
        RepositorySupport.destroy_repo
        VCR.eject_cassette
      end
    end

    class ErratumTest < ErratumTestBase
      def test_backend_data
        RepositorySupport.repo.index_db_errata
        erratum = Pulp::Erratum.new(Erratum.find_by_errata_id(@@full_errata_id).uuid)
        assert @@full_errata_id, erratum .backend_data['id']
      end

      def test_pulp_data
        RepositorySupport.repo.index_db_errata
        uuid = Erratum.find_by_errata_id(@@full_errata_id).uuid
        assert @@full_errata_id, Pulp::Erratum.pulp_data(uuid)['id']
      end

      def test_update_from_json
        uuid = RepositorySupport.repo.errata_json.detect { |e| e['id'] == @@full_errata_id }['_id']
        errata_data =  Pulp::Erratum.pulp_data(uuid)
        erratum = Erratum.create!(:uuid => errata_data['_id'])
        erratum.update_from_json(errata_data)
        %w(title severity issued description solution updated summary).each do |attr|
          assert erratum.send(attr)
        end
        assert_equal Erratum::SECURITY, erratum.errata_type

        erratum.reload
        refute_empty erratum.packages
        refute erratum.packages.first.filename.blank?
        refute erratum.packages.first.nvrea.blank?
        refute erratum.packages.first.name.blank?

        refute_empty erratum.bugzillas
        refute_empty erratum.bugzillas.first.bug_id
        refute_empty erratum.bugzillas.first.href

        refute_empty erratum.cves
        refute_empty erratum.cves.first.cve_id
        refute_empty erratum.cves.first.href
      end
    end
  end
end
