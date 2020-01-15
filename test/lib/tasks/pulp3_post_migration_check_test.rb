require 'katello_test_helper'
require 'rake'

module Katello
  class Pulp3ContentSwitchoverTest < ActiveSupport::TestCase
    def setup
      @fake_pulp3_href = 'fake_pulp3_href'
      @another_fake_pulp3_href = 'another_fake_pulp3_href'

      Katello::Pulp3::Migration::CONTENT_TYPES.each do |model|
        model.all.each do |record|
          record.update(:migrated_pulp3_href => @fake_pulp3_href + record.id.to_s)
        end
      end

      Rake.application.rake_require 'katello/tasks/pulp3_content_switchover'
      @task_name = 'katello:pulp3_content_switchover'
      Rake::Task[@task_name].reenable
      Rake::Task.define_task(:environment)
    end

    def test_file_unit_pulp_ids_updated
      file_unit = katello_files(:one)

      file_unit.update(:migrated_pulp3_href => @another_fake_pulp3_href)

      refute_equal @another_fake_pulp3_href, file_unit.reload.pulp_id
      Rake::Task[@task_name].invoke
      assert_equal @another_fake_pulp3_href, file_unit.reload.pulp_id
    end

    def test_file_unit_with_null_migrated_pulp3_href_throws_an_error
      file_unit = katello_files(:two)
      file_unit.update(:migrated_pulp3_href => nil)

      assert_raises SystemExit do
        Rake::Task[@task_name].invoke
      end
    end

    def test_docker_manifest_pulp_ids_updated
      manifest = FactoryBot.create(:docker_manifest)
      manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href)

      refute_equal @another_fake_pulp3_href, manifest.reload.pulp_id
      Rake::Task[@task_name].invoke
      assert_equal @another_fake_pulp3_href, manifest.reload.pulp_id
    end

    def test_docker_manifest_with_null_migrated_pulp3_href_throws_an_error
      Katello::DockerManifest.first.update(:migrated_pulp3_href => nil)

      assert_raises SystemExit do
        Rake::Task[@task_name].invoke
      end
    end

    def test_docker_manifest_list_pulp_ids_updated
      manifest_list = FactoryBot.create(:docker_manifest_list)
      manifest_list.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      docker_manifest = manifest_list.docker_manifests.first
      docker_manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href + docker_manifest.id.to_s)

      refute_equal @another_fake_pulp3_href, manifest_list.reload.pulp_id
      Rake::Task[@task_name].invoke
      assert_equal @another_fake_pulp3_href, manifest_list.reload.pulp_id
    end

    def test_docker_manifest_list_with_null_migrated_pulp3_href_throws_an_error
      manifest_list = FactoryBot.create(:docker_manifest_list)
      manifest_list.update(:migrated_pulp3_href => nil)

      assert_raises SystemExit do
        Rake::Task[@task_name].invoke
      end
    end

    def test_docker_tag_pulp_ids_updated
      repo = Repository.find(katello_repositories(:busybox).id)
      tag = create(:docker_tag, :repositories => [repo])
      tag.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      docker_manifest = tag.docker_taggable
      docker_manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href + docker_manifest.id.to_s)

      refute_equal @another_fake_pulp3_href, tag.pulp_id
      Rake::Task[@task_name].invoke
      assert_equal @another_fake_pulp3_href, tag.reload.pulp_id
    end

    def test_docker_manifest_tag_with_null_migrated_pulp3_href_throws_an_error
      repo = Repository.find(katello_repositories(:busybox).id)
      tag = create(:docker_tag, :repositories => [repo])
      tag.update(:migrated_pulp3_href => nil)
      docker_manifest = tag.docker_taggable
      docker_manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href + docker_manifest.id.to_s)

      assert_raises SystemExit do
        Rake::Task[@task_name].invoke
      end
    end

    def test_rpm_pulp_ids_not_updated
      rpm = katello_rpms(:one)
      pulp_id = rpm.pulp_id

      Rake::Task[@task_name].invoke
      assert_equal pulp_id, rpm.reload.pulp_id
    end
  end
end
