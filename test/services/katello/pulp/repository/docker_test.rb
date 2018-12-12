require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class DockerBaseTest < ::ActiveSupport::TestCase
        include VCR::TestCase
        include RepositorySupport

        def setup
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy)
          @mirror = FactoryBot.build(:smart_proxy, :pulp_mirror)

          @repo = katello_repositories(:busybox)
        end

        def delete_repo(repo)
          ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Destroy, :pulp_id => repo.pulp_id) rescue ''
        end
      end

      class DockerVcrTest < DockerBaseTest
        def setup
          super
          delete_repo(@repo)
        end

        def test_create
          @repo.root.mirror_on_sync = true

          service = Katello::Pulp::Repository::Docker.new(@repo, @master)
          response = service.create
          assert_equal @repo.pulp_id, response['id']

          importer = service.backend_data['importers'][0]['config']
          assert_equal importer['upstream_name'], @repo.docker_upstream_name

          distributor = service.backend_data['distributors'].find { |dist| dist['distributor_type_id'] == 'docker_distributor_web' }
          assert_equal @repo.container_repository_name, distributor['config']['repo-registry-id']
          assert_equal 1, service.backend_data['distributors'].count
        ensure
          delete_repo(@repo)
        end

        def test_unit_keys
          upload = {'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'}
          assert_equal [upload.except('id')], @repo.backend_service(@master).unit_keys([upload])
        end

        def test_unit_type_id_docker_manifest
          uploads = [{'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'}]
          assert_equal 'docker_manifest', @repo.backend_service(@master).unit_type_id(uploads)
        end

        def test_unit_type_id_docker_tag
          uploads = [{'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test', 'digest' => 'sha256:1234'}]
          assert_equal 'docker_tag', @repo.backend_service(@master).unit_type_id(uploads)
        end
      end
    end
  end
end
