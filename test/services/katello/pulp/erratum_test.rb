require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Service
    class ErratumVcrTestBase < ActiveSupport::TestCase
      include RepositorySupport

      ERRATA_ID = 'KATELLO-RHSA-2010:0858'.freeze

      def setup
        User.current = users(:admin)

        @repo = katello_repositories(:fedora_17_x86_64)
        RepositorySupport.create_and_sync_repo(@repo)
      end

      def teardown
        RepositorySupport.destroy_repo(@repo)
      end
    end

    class ErratumVcrTest < ErratumVcrTestBase
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

      def test_update_model
        uuid = Katello::Pulp::Erratum.fetch_for_repository(@repo.pulp_id).detect { |e| e['id'] == ERRATA_ID }['_id']
        service = Pulp::Erratum.new(uuid)
        erratum = Erratum.create!(:pulp_id => uuid)

        service.update_model(erratum)
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

    class ErratumTest < ActiveSupport::TestCase
      def test_update_model_desc
        errata = katello_errata(:security)
        json = errata.attributes.merge('description' => 'an update', 'updated' => Time.now, 'reboot_suggested' => true).as_json
        service = Pulp::Erratum.new(errata.pulp_id)

        service.backend_data = json
        service.update_model(errata)

        errata.reload
        assert_equal errata.description, json['description']
        assert errata.reboot_suggested
      end

      def test_update_model_is_idempotent
        errata = katello_errata(:security)
        last_updated = errata.updated_at
        json = errata.attributes.as_json
        service = Pulp::Erratum.new(errata.pulp_id)

        service.backend_data = json
        service.update_model(errata)

        assert_equal Erratum.find(errata.id).updated_at, last_updated
      end

      def test_update_model_without_updated_date
        errata = katello_errata(:singletonissue)
        issued_at = errata.issued
        service = Pulp::Erratum.new(errata.pulp_id)
        service.backend_data = errata.attributes.as_json

        service.update_model(errata)

        assert_equal Erratum.find(errata.id).updated, issued_at
      end

      def test_update_model_truncates_title
        errata = katello_errata(:security)
        title = "There is a tide in the affairs of men, Which taken at the flood, leads on to " \
          "fortune.  Omitted, all the voyage of their life is bound in shallows and in miseries. "\
          "On such a full sea are we now afloat. And we must take the current when it serves, or "\
          "lose our ventures. - William Shakespeare"
        json = errata.attributes.merge('description' => 'an update', 'updated' => Time.now, 'title' => title).as_json
        service = Pulp::Erratum.new(errata.pulp_id)
        service.backend_data = json
        service.update_model(errata)

        assert_equal Erratum.find(errata.id).title.size, 255
      end

      def test_update_model_duplicate_packages
        pkg = {:name => 'foo', :version => 3, :arch => 'x86_64', :epoch => 0, :release => '.el3', :filename => 'blahblah.rpm'}.with_indifferent_access
        pkg_list = [pkg, pkg]
        errata = katello_errata(:security)

        pkg_count = errata.packages.count
        json = errata.attributes.merge('description' => 'an update', 'updated' => Time.now, 'pkglist' => [{'packages' => pkg_list}]).as_json
        service = Pulp::Erratum.new(errata.pulp_id)
        service.backend_data = json
        service.update_model(errata)

        assert_equal errata.reload.packages.count, pkg_count + 1
      end

      def test_update_model_new_packages
        pkg = {:name => 'foo', :version => 3, :arch => 'x86_64', :epoch => 0, :release => '.el3', :filename => 'blahblah.rpm'}.with_indifferent_access
        pkg2 = {:name => 'bar', :version => 3, :arch => 'x86_64', :epoch => 0, :release => '.el3', :filename => 'foo.rpm'}.with_indifferent_access
        errata = katello_errata(:security)
        pkg_count = errata.packages.count
        json = errata.attributes.merge('pkglist' => [{'packages' => [pkg]}]).as_json

        service = Pulp::Erratum.new(errata.pulp_id)
        service.backend_data = json
        service.update_model(errata)

        assert_equal errata.reload.packages.count, pkg_count + 1

        json = errata.attributes.merge('pkglist' => [{'packages' => [pkg, pkg2]}]).as_json
        service.backend_data = json
        service.update_model(errata)

        assert_equal errata.reload.packages.count, pkg_count + 2
        assert_empty errata.module_streams
        assert_equal errata.packages.non_module_stream_packages.count, pkg_count + 2
      end

      def test_update_model_modules
        pkg = {:name => 'foo', :version => 3, :arch => 'x86_64', :epoch => 0, :release => '.el3', :filename => 'blahblah.rpm'}.with_indifferent_access
        module_stream = katello_module_streams(:river)
        module_stream_json = module_stream.module_spec_hash
        errata = katello_errata(:security)
        pkg_count = errata.packages.count

        json = errata.attributes.merge('pkglist' => [{'packages' => [pkg], 'module' => module_stream_json}]).as_json
        service = Pulp::Erratum.new(errata.pulp_id)
        service.backend_data = json
        service.update_model(errata)

        assert_equal errata.reload.packages.count, pkg_count + 1
        assert_equal errata.module_streams.count, 1
        assert_equal errata.module_streams.first, module_stream.module_spec_hash.merge(:packages => [Util::Package.build_nvra(pkg)])
        assert_equal errata.reload.packages.non_module_stream_packages.count, pkg_count
      end

      def test_update_model_epoch_dates
        now = Time.now
        epoch = now.to_i.to_s

        errata = katello_errata(:security)
        json = errata.attributes.merge('issued' => epoch, 'updated' => epoch).as_json
        service = Pulp::Erratum.new(errata.pulp_id)
        service.backend_data = json
        service.update_model(errata)

        errata = Erratum.find(errata.id)
        assert_equal errata.issued.to_date, now.to_date
        assert_equal errata.updated.to_date, now.to_date
      end
    end
  end
end
