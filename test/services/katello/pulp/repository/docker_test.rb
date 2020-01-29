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
          @repo_copy = katello_repositories(:busybox2)
        end

        def delete_repo(repo)
          ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Destroy, :repository_id => repo.id) rescue ''
        end
      end

      class DockerMirrorTest < DockerBaseTest
        def setup
          super
          Cert::Certs.stubs(:ueber_cert).returns({})
        end

        def strip_host(url)
          URI.parse(url).host
        end

        def test_mirror_importer_with_pulp2
          service = Katello::Pulp::Repository::Docker.new(@repo, @mirror)

          assert_equal "https://#{strip_host(SmartProxy.pulp_master.pulp_url)}:5000", service.generate_mirror_importer.feed
        end

        def test_mirror_importer_with_pulp3
          @master.destroy!
          FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          service = Katello::Pulp::Repository::Docker.new(@repo, @mirror)

          assert_equal "https://#{strip_host(Setting[:foreman_url])}", service.generate_mirror_importer.feed
        end
      end

      class DockerVcrTest < DockerBaseTest
        def setup
          super
          delete_repo(@repo)
          delete_repo(@repo_copy)
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

        def test_index_content
          @repo.root.mirror_on_sync = true

          service = Katello::Pulp::Repository::Docker.new(@repo, @master)
          service.create
          service2 = Katello::Pulp::Repository::Docker.new(@repo_copy, @master)
          service2.create
          RepositorySupport.create_and_sync_repo(@repo)
          RepositorySupport.create_repo(@repo_copy)

          @repo.index_content
          assert @repo.docker_tags.count > 0
          TaskSupport.wait_on_tasks(service.copy_contents(@repo_copy))
          @repo_copy.index_content(:source_repository => @repo)
          assert_equal @repo_copy.docker_tags.count, @repo.docker_tags.count
        ensure
          delete_repo(@repo)
          delete_repo(@repo_copy)
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

      class DockerCopyContentsTest < ::ActiveSupport::TestCase
        def test_filter_criteria_is_not_empty
          @repo = katello_repositories(:busybox)

          filter = FactoryBot.create(:katello_content_view_docker_filter)
          docker_tag = mock
          docker_tag.expects(:copy).with do |_, _, criteria|
            criteria != { :filters => { :unit => nil }}
          end
          extensions = mock
          extensions.stubs(:docker_tag).returns(docker_tag)
          pulp_api = mock
          pulp_api.stubs(:extensions).returns(extensions)
          smart_proxy = mock
          smart_proxy.stubs(:pulp_api).returns(pulp_api)

          destination_repo = mock
          destination_repo.stubs(:pulp_id).returns("234832")

          service = Katello::Pulp::Repository::Docker.new(@repo, smart_proxy)
          service.copy_contents(destination_repo, :filters => [filter])
        end
      end
    end
  end
end
