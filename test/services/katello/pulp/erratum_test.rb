require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Service
    class ErratumTestBase < ActiveSupport::TestCase
      include RepositorySupport

      ERRATA_ID = 'RHSA-2010:0858'.freeze

      def setup
        User.current = users(:admin)

        @repo = katello_repositories(:fedora_17_x86_64)
        RepositorySupport.create_and_sync_repo(@repo)
      end

      def teardown
        RepositorySupport.destroy_repo(@repo)
      end
    end

    class ErratumTest < ErratumTestBase
      def test_backend_data
        Katello::Erratum.import_for_repository(@repo)
        erratum = Pulp::Erratum.new(Erratum.find_by_errata_id(ERRATA_ID).pulp_id)
        assert ERRATA_ID, erratum .backend_data['id']
      end

      def test_pulp_data
        Katello::Erratum.import_for_repository(@repo)
        uuid = Erratum.find_by_errata_id(ERRATA_ID).pulp_id
        assert ERRATA_ID, Pulp::Erratum.pulp_data(uuid)['id']
      end

      def test_update_from_json
        uuid = Katello::Pulp::Erratum.fetch_for_repository(@repo.pulp_id).detect { |e| e['id'] == ERRATA_ID }['_id']
        errata_data = Pulp::Erratum.pulp_data(uuid)
        erratum = Erratum.create!(:pulp_id => errata_data['_id'])
        erratum.update_from_json(errata_data)
        %w(title severity issued description solution updated summary).each do |attr|
          assert erratum.send(attr)
        end
        assert_includes Erratum::SECURITY, erratum.errata_type

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
