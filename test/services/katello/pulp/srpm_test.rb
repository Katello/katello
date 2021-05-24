require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Services
    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
    end

    class SrpmNonVcrTest < ActiveSupport::TestCase
      def test_update_model
        pulp_id = 'foo'
        model = Srpm.create!(:pulp_id => pulp_id)
        json = model.attributes.merge('summary' => 'an update', 'version' => '3', 'release' => '4')

        service = Katello::Pulp::Srpm.new(pulp_id)
        service.backend_data = json
        service.update_model(model)

        model = model.reload

        assert_equal model.summary, json['summary']
        refute model.release_sortable.blank?
        refute model.version_sortable.blank?
        refute model.nvra.blank?
      end

      def test_update_model_is_idempotent
        srpm = katello_srpms(:one)
        last_updated = srpm.updated_at
        json = srpm.attributes

        service = Katello::Pulp::Srpm.new(srpm.pulp_id)
        service.backend_data = json
        service.update_model(srpm)

        assert_equal srpm.reload.updated_at, last_updated
      end
    end

    class RpmTestBase < ActiveSupport::TestCase
      include RepositorySupport

      def setup
        User.current = users(:admin)

        @repo = katello_repositories(:fedora_17_x86_64)

        RepositorySupport.create_and_sync_repo(@repo)
        Katello::Rpm.import_for_repository(@repo)
        @package_id = @repo.rpms.find_by_name('cheetah').id
      end

      def teardown
        RepositorySupport.destroy_repo(@repo)
        User.current = nil
      end
    end

    class RpmTest < RpmTestBase
      def test_find
        package = Rpm.find(@package_id)

        refute_nil package
        refute_empty Katello::Pulp::Rpm.new(package.pulp_id).backend_data
      end

      def test_requires
        package = Rpm.find(@package_id)
        backend_rpm = Katello::Pulp::Rpm.new(package.pulp_id)
        refute_empty backend_rpm .requires, "Backend (pulp) rpm requires was empty"
        refute_empty backend_rpm .provides, "Backend (pulp) rpm provides was empty"
      end

      def test_ignored_fields
        refute_includes Katello::Pulp::Rpm::PULP_SELECT_FIELDS, 'changelog'
        refute_includes Katello::Pulp::Rpm::PULP_SELECT_FIELDS, 'repodata'
        refute_includes Katello::Pulp::Rpm::PULP_SELECT_FIELDS, 'filelist'
      end
    end
  end
end
