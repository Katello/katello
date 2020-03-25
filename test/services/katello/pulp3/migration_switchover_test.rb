require 'katello_test_helper'

module Katello
  class SwitchoverBase < ActiveSupport::TestCase
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      SETTINGS[:katello][:use_pulp_2_for_content_type] = {:file => true, :docker => true}
    end

    def teardown
      SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = nil
      SETTINGS[:katello][:use_pulp_2_for_content_type][:docker] = nil
    end
  end

  class Pulp3ContentSwitchoverTest < SwitchoverBase
    def setup
      super

      @fake_pulp3_href = 'fake_pulp3_href'
      @another_fake_pulp3_href = 'another_fake_pulp3_href'

      migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_master, ['file', 'docker'])
      migration_service.content_types_for_migration.each do |content_type|
        content_type.model_class.all.each do |record|
          record.update(:migrated_pulp3_href => @fake_pulp3_href + record.id.to_s)
        end
      end

      @switchover = Katello::Pulp3::MigrationSwitchover.new(SmartProxy.pulp_master, ['file', 'docker'])
    end

    def test_file_unit_pulp_ids_updated
      file_unit = katello_files(:one)
      file_unit.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      refute_equal @another_fake_pulp3_href, file_unit.reload.pulp_id

      @switchover.run

      assert_equal @another_fake_pulp3_href, file_unit.reload.pulp_id
    end

    def test_file_unit_with_null_migrated_pulp3_href_throws_an_error
      file_unit = katello_files(:two)
      file_unit.update(:migrated_pulp3_href => nil)

      assert_raises Katello::Pulp3::SwitchoverError do
        @switchover.run
      end
    end

    def test_docker_manifest_pulp_ids_updated
      manifest = FactoryBot.create(:docker_manifest)
      manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      refute_equal @another_fake_pulp3_href, manifest.reload.pulp_id

      @switchover.run

      assert_equal @another_fake_pulp3_href, manifest.reload.pulp_id
    end

    def test_docker_manifest_with_null_migrated_pulp3_href_throws_an_error
      Katello::DockerManifest.first.update(:migrated_pulp3_href => nil)

      assert_raises Katello::Pulp3::SwitchoverError do
        @switchover.run
      end
    end

    def test_docker_manifest_list_pulp_ids_updated
      manifest_list = FactoryBot.create(:docker_manifest_list)
      manifest_list.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      docker_manifest = manifest_list.docker_manifests.first
      docker_manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href + docker_manifest.id.to_s)
      refute_equal @another_fake_pulp3_href, manifest_list.reload.pulp_id

      @switchover.run

      assert_equal @another_fake_pulp3_href, manifest_list.reload.pulp_id
    end

    def test_docker_manifest_list_with_null_migrated_pulp3_href_throws_an_error
      manifest_list = FactoryBot.create(:docker_manifest_list)
      manifest_list.update(:migrated_pulp3_href => nil)

      assert_raises Katello::Pulp3::SwitchoverError do
        @switchover.run
      end
    end

    def test_docker_tag_pulp_ids_updated
      repo = Repository.find(katello_repositories(:busybox).id)
      tag = create(:docker_tag, :repositories => [repo])
      tag.update(:migrated_pulp3_href => @another_fake_pulp3_href)
      tag.update(:pulp_id => "areallyfakepulpid")
      docker_manifest = tag.docker_taggable
      docker_manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href + docker_manifest.id.to_s)

      refute_equal @another_fake_pulp3_href, tag.reload.pulp_id

      @switchover.run
      assert_equal @another_fake_pulp3_href, tag.reload.pulp_id
    end

    def test_docker_manifest_tag_with_null_migrated_pulp3_href_throws_an_error
      repo = Repository.find(katello_repositories(:busybox).id)
      tag = create(:docker_tag, :repositories => [repo])
      tag.update(:migrated_pulp3_href => nil)
      docker_manifest = tag.docker_taggable
      docker_manifest.update(:migrated_pulp3_href => @another_fake_pulp3_href + docker_manifest.id.to_s)

      assert_raises Katello::Pulp3::SwitchoverError do
        @switchover.run
      end
    end

    def test_rpm_pulp_ids_not_updated
      rpm = katello_rpms(:one)
      pulp_id = rpm.pulp_id

      @switchover.run
      assert_equal pulp_id, rpm.reload.pulp_id
    end
  end

  class Pulp3ContentSwitchoverDuplicateDockerTest < SwitchoverBase
    def setup
      super

      @repo = katello_repositories(:busybox)
      @cv_archive_repo = katello_repositories(:busybox_view1)

      Katello::RootRepository.docker_type.where.not(:id => @repo.root_id).destroy_all
      @switchover_service = Katello::Pulp3::MigrationSwitchover.new(@master, ['docker'])

      Katello::DockerTag.destroy_all
      Katello::DockerManifest.destroy_all
      @tag1 = FactoryBot.create(:docker_tag, :latest)
      @tag1.update(:migrated_pulp3_href => "/foo/bar")
      @tag1.docker_manifest_list.update(:migrated_pulp3_href => "/foo/manifest")
      @repo.docker_tags << @tag1

      @tag2 = FactoryBot.create(:docker_tag, :latest)
      @tag2.update(:migrated_pulp3_href => "/foo/bar")
      @tag2.docker_manifest_list.update(:migrated_pulp3_href => "/foo/manifest2")
      @cv_archive_repo.docker_tags << @tag2
    end

    def test_docker_tag_cleanup
      assert_equal 2, Katello::DockerTag.count
      @switchover_service.run
      assert_equal 1, Katello::DockerTag.count
      tag = Katello::DockerTag.first
      assert_include tag.repositories, @repo
      assert_include tag.repositories, @cv_archive_repo
    end
  end
end
