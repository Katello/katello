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
    let(:simplified_acs) { katello_alternate_content_sources(:yum_simplified_alternate_content_source) }
    let(:proxy) { SmartProxy.pulp_primary }
    let(:mirror) { @proxy_mirror = FactoryBot.build(:smart_proxy, :pulp_mirror, :url => 'http://fakemirrorpath.com/foo') }
    let(:product) { katello_products(:redhat) }
    let(:fedora) { katello_products(:fedora) }

    before do
      # verify_ssl is 'true' by default for ACSs, but it doesn't make sense for simplified ones.
      simplified_acs.verify_ssl = nil
    end
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::AlternateContentSource::Create }
    let(:pulp3_action_class) { ::Actions::Pulp3::Orchestration::AlternateContentSource::Create }

    before do
      mirror.save!
    end

    it 'plans' do
      action.expects(:action_subject).with(acs)
      proxy_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.new(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      mirror_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.new(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id).returns(proxy_smart_proxy_acs)
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id).returns(mirror_smart_proxy_acs)
      plan_action action, acs, [proxy, mirror]
      assert_action_planned_with action, pulp3_action_class, proxy_smart_proxy_acs
      assert_action_planned_with action, pulp3_action_class, mirror_smart_proxy_acs
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
    end

    it 'plans to create during update' do
      action.expects(:action_subject).with(acs)
      proxy_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.new(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      mirror_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.new(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id).returns(proxy_smart_proxy_acs)
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id).returns(mirror_smart_proxy_acs)
      plan_action action, acs, [proxy, mirror], [], {}
      assert_action_planned_with action, pulp3_action_create_class, proxy_smart_proxy_acs
      assert_action_planned_with action, pulp3_action_create_class, mirror_smart_proxy_acs
    end

    it 'plans to create simplified during update' do
      action.expects(:action_subject).with(simplified_acs)
      smart_proxy_acss = []
      repo_without_url = FactoryBot.create(:katello_repository, :content_type => 'yum', :product_id => fedora.id, :environment => fedora.organization.library,
                                           :content_view_version => fedora.organization.default_content_view.versions.first, :download_policy => 'on_demand')
      repo_without_url.root.update!(url: nil)
      fedora.repositories.with_type('yum').library.each do |repo|
        proxy_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.new(alternate_content_source_id: simplified_acs.id, smart_proxy_id: proxy.id, repository_id: repo.id)
        mirror_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.new(alternate_content_source_id: simplified_acs.id, smart_proxy_id: mirror.id, repository_id: repo.id)
        if repo.root.url.nil?
          ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: simplified_acs.id, smart_proxy_id: proxy.id, repository_id: repo.id).never
          ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: simplified_acs.id, smart_proxy_id: mirror.id, repository_id: repo.id).never
        else
          ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: simplified_acs.id, smart_proxy_id: proxy.id, repository_id: repo.id).returns(proxy_smart_proxy_acs)
          ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: simplified_acs.id, smart_proxy_id: mirror.id, repository_id: repo.id).returns(mirror_smart_proxy_acs)
          smart_proxy_acss << proxy_smart_proxy_acs
          smart_proxy_acss << mirror_smart_proxy_acs
        end
      end
      plan_action action, simplified_acs, [proxy, mirror], [fedora], {}
      smart_proxy_acss.each do |smart_proxy_acs|
        assert_action_planned_with action, pulp3_action_create_class, smart_proxy_acs
      end
    end

    it 'fails to create simplified during update with empty product' do
      action.expects(:action_subject).with(simplified_acs)
      empty_product = ::Katello::Product.create(name: 'empty', organization_id: ::Organization.first)
      assert_raises ActiveRecord::RecordInvalid do
        plan_action action, simplified_acs, [proxy, mirror], [empty_product], {}
      end
    end

    it 'plans to update during update' do
      action.expects(:action_subject).with(acs)
      proxy_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      mirror_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id).returns(proxy_smart_proxy_acs).never
      ::Katello::SmartProxyAlternateContentSource.expects(:create).with(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id).returns(mirror_smart_proxy_acs).never
      plan_action action, acs, [proxy, mirror], [], {}
      assert_action_planned_with action, pulp3_action_update_class, proxy_smart_proxy_acs
      assert_action_planned_with action, pulp3_action_update_class, mirror_smart_proxy_acs
    end

    it 'plans to delete during update' do
      action.expects(:action_subject).with(acs)
      proxy_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      mirror_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      plan_action action, acs, [], [], {}
      assert_action_planned_with action, pulp3_action_delete_class, proxy_smart_proxy_acs
      assert_action_planned_with action, pulp3_action_delete_class, mirror_smart_proxy_acs
    end

    it 'plans to delete simplified during product removal update' do
      action.expects(:action_subject).with(simplified_acs)
      smart_proxy_acss = []
      simplified_acs.products << product
      product.repositories.library.each do |repo|
        proxy_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: simplified_acs.id, smart_proxy_id: proxy.id, repository_id: repo.id)
        mirror_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: simplified_acs.id, smart_proxy_id: mirror.id, repository_id: repo.id)
        smart_proxy_acss << proxy_smart_proxy_acs
        smart_proxy_acss << mirror_smart_proxy_acs
      end
      plan_action action, simplified_acs, [proxy, mirror], [], {}
      smart_proxy_acss.each do |smart_proxy_acs|
        assert_action_planned_with action, pulp3_action_delete_class, smart_proxy_acs
      end
    end

    it 'plans to delete simplified during proxy removal update' do
      action.expects(:action_subject).with(simplified_acs)
      smart_proxy_acss = []
      simplified_acs.products << product
      product.repositories.library.each do |repo|
        proxy_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: simplified_acs.id, smart_proxy_id: proxy.id, repository_id: repo.id)
        mirror_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: simplified_acs.id, smart_proxy_id: mirror.id, repository_id: repo.id)
        smart_proxy_acss << proxy_smart_proxy_acs
        smart_proxy_acss << mirror_smart_proxy_acs
      end
      plan_action action, simplified_acs, [], [product], {}
      smart_proxy_acss.each do |smart_proxy_acs|
        assert_action_planned_with action, pulp3_action_delete_class, smart_proxy_acs
      end
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::AlternateContentSource::Destroy }
    let(:pulp3_action_class) { ::Actions::Pulp3::Orchestration::AlternateContentSource::Delete }

    before do
      mirror.save!
    end

    it 'plans' do
      action.expects(:action_subject).with(acs)
      proxy_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: proxy.id)
      mirror_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: mirror.id)
      plan_action action, acs
      assert_action_planned_with action, pulp3_action_class, proxy_smart_proxy_acs
      assert_action_planned_with action, pulp3_action_class, mirror_smart_proxy_acs
    end

    it 'plans simplified' do
      action.expects(:action_subject).with(simplified_acs)
      smart_proxy_acss = []
      simplified_acs.products << product
      product.repositories.library.each do |repo|
        proxy_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: simplified_acs.id, smart_proxy_id: proxy.id, repository_id: repo.id)
        mirror_smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: simplified_acs.id, smart_proxy_id: mirror.id, repository_id: repo.id)
        smart_proxy_acss << proxy_smart_proxy_acs
        smart_proxy_acss << mirror_smart_proxy_acs
      end
      plan_action action, simplified_acs
      smart_proxy_acss.each do |smart_proxy_acs|
        assert_action_planned_with action, pulp3_action_class, smart_proxy_acs
      end
    end
  end
end
