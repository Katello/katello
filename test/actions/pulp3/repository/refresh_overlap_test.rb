require 'katello_test_helper'

module ::Actions::Pulp3::Repository
  class RefreshOverlapTest < ActiveSupport::TestCase
    include Dynflow::Testing

    def setup
      @previous_user = User.current
      User.current = users(:admin)
      @repo = katello_repositories(:busybox)
      @other = katello_repositories(:redis)
      @repo.update_column(:container_repository_name, 'legacy/parent')
      @repo.reload
      @proxy = SmartProxy.pulp_primary
      @capsule = smart_proxies(:four)
      ::Katello::Pulp3::DistributionReference.delete_all
      reference(@repo, 'legacy/parent', '/pulp/dist/own/')
      reference(@other, 'legacy/parent/child', '/pulp/dist/other/')
    end

    def teardown
      User.current = @previous_user
    end

    def reference(repository, path, href)
      ::Katello::Pulp3::DistributionReference.create!(repository: repository, path: path, href: href)
    end

    test 'primary refresh rejects before planning content guards or distribution work' do
      action = create_action(::Actions::Pulp3::Repository::RefreshDistribution)
      action.expects(:plan_action).never
      action.expects(:plan_self).never
      assert_raises(::Katello::HttpErrors::Conflict) { action.plan(@repo, @proxy.id) }
    end

    test 'capsule refresh uses primary references as a conservative backstop' do
      action = create_action(::Actions::Pulp3::CapsuleContent::RefreshDistribution)
      action.expects(:plan_self).never
      assert_raises(::Katello::HttpErrors::Conflict) { action.plan(@repo, @capsule) }
    end

    test 'anonymous background refresh errors hide both paths and repository names' do
      User.current = User.anonymous_api_admin
      [::Actions::Pulp3::Repository::RefreshDistribution, ::Actions::Pulp3::CapsuleContent::RefreshDistribution].each do |klass|
        proxy = klass == ::Actions::Pulp3::Repository::RefreshDistribution ? @proxy.id : @capsule
        error = assert_raises(::Katello::HttpErrors::Conflict) { create_action(klass).plan(@repo, proxy) }
        assert_not_includes error.message, 'legacy/parent'
        assert_not_includes error.message, @other.name
        assert_includes error.message, 'administrator'
      end
    end

    test 'non-container and unknown paths do not trigger the check' do
      [katello_repositories(:fedora_17_x86_64), @repo].each_with_index do |repo, index|
        repo.stubs(:container_repository_name).returns(nil) if index == 1
        action = create_action(::Actions::Pulp3::CapsuleContent::RefreshDistribution)
        action.expects(:plan_self).once
        action.plan(repo, @capsule)
      end
    end

    test 'safe primary refresh still plans the distribution' do
      @repo.update_column(:container_repository_name, 'safe/repaired')
      @repo.reload
      action = create_action(::Actions::Pulp3::Repository::RefreshDistribution)
      plan_action(action, @repo, @proxy.id)
      assert_action_planned(action, ::Actions::Pulp3::Repository::SaveDistributionReferences)
    end

    test 'safe capsule path is not blocked by unrelated primary overlaps' do
      @repo.update_column(:container_repository_name, 'safe/repaired')
      @repo.reload
      action = create_action(::Actions::Pulp3::CapsuleContent::RefreshDistribution)
      action.expects(:plan_self).once
      action.plan(@repo, @capsule)
    end
  end
end
