require 'katello_test_helper'

class Dynflow::Testing::DummyPlannedAction
  attr_accessor :error
end

class Dynflow::Testing::DummyExecutionPlan
  attr_accessor :error

  def run_steps
    []
  end
end

module ::Actions::Katello::AlternateContentSource
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action) { create_action action_class }
    let(:acs) { katello_alternate_content_sources(:yum_alternate_content_source) }
    let(:proxy) { SmartProxy.pulp_primary }
    let(:mirror) { @proxy_mirror = FactoryBot.build(:smart_proxy, :pulp_mirror, :url => 'http://fakemirrorpath.com/foo') }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::AlternateContentSource::Create }
    let(:pulp3_action_class) { ::Actions::Pulp3::Orchestration::AlternateContentSource::Create }

    before do
      mirror.save!
      action.expects(:action_subject).with(acs)
    end

    it 'plans' do
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      plan_action action, acs, [proxy, mirror]
      assert_action_planned_with action, pulp3_action_class, acs, proxy
      assert_action_planned_with action, pulp3_action_class, acs, mirror
    end
  end

  class CreateFailTest < TestBase
    let(:action_class) { ::Actions::Katello::AlternateContentSource::Create }
    before do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns("ERROR")
    end

    it 'fails to plan' do
      acs.expects(:save!).never
    end
  end

  class UpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::AlternateContentSource::Update }
    let(:pulp3_action_create_class) { ::Actions::Pulp3::Orchestration::AlternateContentSource::Create }
    let(:pulp3_action_delete_class) { ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete }
    let(:pulp3_action_update_class) { ::Actions::Pulp3::Orchestration::AlternateContentSource::Update }

    before do
      mirror.save!
      action.expects(:action_subject).with(acs)
    end

    it 'plans to create during update' do
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      plan_action action, acs, [proxy, mirror], {}
      assert_action_planned_with action, pulp3_action_create_class, acs, proxy
      assert_action_planned_with action, pulp3_action_create_class, acs, mirror
    end

    it 'plans to update during update' do
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      plan_action action, acs, [proxy, mirror], {}
      assert_action_planned_with action, pulp3_action_update_class, acs, proxy
      assert_action_planned_with action, pulp3_action_update_class, acs, mirror
    end

    it 'plans to delete during update' do
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      plan_action action, acs, [], {}
      assert_action_planned_with action, pulp3_action_delete_class, acs, proxy
      assert_action_planned_with action, pulp3_action_delete_class, acs, mirror
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::AlternateContentSource::Destroy }
    let(:pulp3_action_class) { ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete }

    before do
      mirror.save!
      action.expects(:action_subject).with(acs)
    end

    it 'plans' do
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      plan_action action, acs
      assert_action_planned_with action, pulp3_action_class, acs, proxy
      assert_action_planned_with action, pulp3_action_class, acs, mirror
    end
  end
end
