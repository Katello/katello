require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      class DistributionReferenceTest < ActiveSupport::TestCase
        def setup
          @repo = katello_repositories(:pulp3_docker_1)
          @proxy = SmartProxy.pulp_primary
          @service = ::Katello::Pulp3::Repository::Docker.new(@repo, @proxy)
          ::Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).destroy_all
        end

        def create_reference(href = '/pulp/distributions/old/', path = 'old/path')
          ::Katello::Pulp3::DistributionReference.create!(repository_id: @repo.id, href: href, path: path)
        end

        def distribution(path, guard = nil)
          stub(base_path: path, content_guard: guard, prn: 'prn:container.containerdistribution:abc')
        end

        def test_move_updates_referenced_distribution_without_looking_up_target_path
          ref = create_reference
          @service.expects(:read_distribution).with(ref.href).returns(distribution('old/path'))
          @service.expects(:lookup_distributions).never
          @service.expects(:create_distribution).never
          @service.expects(:update_distribution).returns([:task])

          assert_equal [:task], @service.refresh_distributions
          assert_equal 'old/path', ref.reload.path
        end

        def test_stale_reference_is_not_deleted_before_creation_succeeds
          ref = create_reference
          @service.expects(:read_distribution).with(ref.href).returns(nil)
          @service.expects(:lookup_distributions).never
          @service.expects(:create_distribution).with(@service.relative_path).returns([:task])

          assert_equal [:task], @service.refresh_distributions
          assert_equal 'old/path', ref.reload.path
        end

        def test_missing_reference_does_not_adopt_unrelated_distribution
          @service.expects(:lookup_distributions).never
          @service.expects(:create_distribution).with(@service.relative_path).returns([:task])
          assert_equal [:task], @service.refresh_distributions
          assert_nil @service.distribution_reference
        end

        def test_async_update_does_not_write_reference_before_success
          ref = create_reference
          api = mock('api')
          distributions = mock('distributions')
          @service.stubs(:api).returns(api)
          api.stubs(:distributions_api).returns(distributions)
          @service.stubs(:secure_distribution_options).returns(base_path: 'new/path', content_guard_prn: nil)
          task = stub(task: '/pulp/tasks/1/')
          distributions.expects(:partial_update).with(ref.href, { base_path: 'new/path' }).returns(task)

          assert_equal [task], @service.update_distribution
          assert_equal 'old/path', ref.reload.path
        end

        def test_update_error_leaves_reference_unchanged
          ref = create_reference
          api = mock('api')
          distributions = mock('distributions')
          @service.stubs(:api).returns(api)
          api.stubs(:distributions_api).returns(distributions)
          api.stubs(:client_module).returns(PulpContainerClient)
          @service.stubs(:secure_distribution_options).returns(base_path: 'new/path', content_guard_prn: nil)
          distributions.expects(:partial_update).raises(StandardError, 'update failed')

          assert_raises(StandardError) { @service.update_distribution }
          assert_equal 'old/path', ref.reload.path
        end

        def test_create_error_leaves_stale_reference_unchanged
          ref = create_reference
          @service.expects(:read_distribution).with(ref.href).returns(nil)
          @service.expects(:create_distribution).raises(StandardError, 'create failed')

          assert_raises(StandardError) { @service.refresh_distributions }
          assert_equal 'old/path', ref.reload.path
        end

        def test_noop_does_not_write_reference_before_reconciliation
          ref = create_reference
          api = mock('api')
          distributions = mock('distributions')
          @service.stubs(:api).returns(api)
          api.stubs(:distributions_api).returns(distributions)
          @service.stubs(:secure_distribution_options).returns(base_path: 'new/path', content_guard_prn: nil)
          distributions.expects(:partial_update).with(ref.href, { base_path: 'new/path' }).returns(nil)

          assert_empty @service.update_distribution
          assert_equal 'old/path', ref.reload.path
        end

        def test_save_after_success_refreshes_only_from_pulp
          ref = create_reference
          @service.expects(:read_distribution).with(ref.href).returns(distribution('new/path', '/pulp/contentguards/certguard/rhsm/abc/'))

          @service.save_distribution_references([ref.href])
          ref.reload
          assert_equal 'new/path', ref.path
          assert_equal '/pulp/distributions/old/', ref.href
          assert_equal 'prn:container.containerdistribution:abc', ref.prn
          assert_equal 'prn:certguard.rhsmcertguard:abc', ref.content_guard_prn
        end

        def test_created_distribution_is_recorded_after_success
          href = '/pulp/distributions/new/'
          @service.expects(:read_distribution).with(href).returns(distribution('new/path'))

          @service.save_distribution_references([href])
          ref = @service.distribution_reference
          assert_equal href, ref.href
          assert_equal 'new/path', ref.path
        end

        def test_stale_reference_is_replaced_with_created_distribution_data
          ref = create_reference
          new_href = '/pulp/distributions/new/'
          @service.expects(:read_distribution).with(new_href).returns(distribution('new/path'))
          @service.expects(:read_distribution).with(ref.href).returns(nil)

          @service.save_distribution_references([new_href])
          ref.reload
          assert_equal new_href, ref.href
          assert_equal 'new/path', ref.path
          assert_equal 1, ::Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).count
        end

        def test_different_existing_reference_is_not_overwritten_with_new_data
          ref = create_reference
          new_href = '/pulp/distributions/new/'
          @service.expects(:read_distribution).with(new_href).returns(distribution('new/path'))
          @service.expects(:read_distribution).with(ref.href).returns(distribution('old/path'))

          assert_raises(RuntimeError) { @service.save_distribution_references([new_href]) }
          assert_equal 'old/path', ref.reload.path
          assert_equal '/pulp/distributions/old/', ref.href
        end

        def test_missing_created_distribution_keeps_stale_reference
          ref = create_reference
          @service.expects(:read_distribution).with('/pulp/distributions/new/').returns(nil)
          assert_raises(RuntimeError) { @service.save_distribution_references(['/pulp/distributions/new/']) }
          assert_equal 'old/path', ref.reload.path
        end

        def test_generic_path_recovery_is_unchanged
          repo = katello_repositories(:fedora_17_x86_64)
          service = repo.backend_service(@proxy)
          dist = stub(pulp_href: '/pulp/distributions/existing/')
          service.stubs(:distribution_reference).returns(nil)
          service.expects(:lookup_distributions).with(base_path: repo.relative_path).returns([dist])
          service.expects(:save_distribution_references).with([dist.pulp_href])
          service.expects(:update_distribution).returns([:task])
          assert_equal [:task], service.refresh_distributions
        end
      end
    end
  end
end
