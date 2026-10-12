require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      module Api
        class DockerTest < ActiveSupport::TestCase
          def setup
            @api = Katello::Pulp3::Api::Docker.new(SmartProxy.pulp_primary)
            @repositories = mock('repositories_api')
            @api.stubs(:repositories_api).returns(@repositories)
          end

          def test_finds_regular_container_repository_for_push
            repository = stub(pulp_href: '/pulp/api/v3/repositories/container/container/repo/')
            @repositories.expects(:list).with(name: 'org/product/image').returns(stub(results: [repository]))
            @api.expects(:container_push_api).never

            assert_equal repository, @api.container_push_repo_for_name('org/product/image')
          end

          def test_finds_legacy_push_repository
            repository = stub(pulp_href: '/pulp/api/v3/repositories/container/container-push/repo/')
            @repositories.expects(:list).with(name: 'org/product/image').returns(stub(results: []))
            legacy = mock('container_push_api')
            legacy.expects(:list).with(name: 'org/product/image').returns(stub(results: [repository]))
            @api.stubs(:container_push_api).returns(legacy)

            assert_equal repository, @api.container_push_repo_for_name('org/product/image')
          end
        end
      end
    end
  end
end
