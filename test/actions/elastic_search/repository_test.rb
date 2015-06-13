require 'katello_test_helper'

module Actions::ElasticSearch
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include FactoryGirl::Syntax::Methods

    let(:repository) { build(:katello_repository, id: 123) }
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::ElasticSearch::Repository::Destroy }

    it 'runs and clear content' do
      action = create_and_plan_action(action_class, pulp_id: repository.pulp_id)

      [::Katello::PuppetModule].each do |klass|
        klass.expects(:indexed_ids_for_repo).with(repository.pulp_id).returns([1, 2, 3])
        klass.expects(:remove_indexed_repoid).with([1, 2, 3], repository.pulp_id)
      end
      run_action action
    end
  end

  class FilteredIndexContentTest < TestBase
    let(:action_class) { ::Actions::ElasticSearch::Repository::FilteredIndexContent }
    let(:yum_repository) { katello_repositories(:fedora_17_x86_64) }
    let(:puppet_repository) { katello_repositories(:p_forge) }

    context 'yum repository' do
      it 'indexes just units sattisfying the filter' do
        action = create_and_plan_action(action_class,
                                        id: yum_repository.id, filter: { name: 'cheetah' })
        ::Katello::Repository.any_instance.expects(:unit_search).
            with(type_ids: ['rpm'], filters: { 'name' => 'cheetah' }).returns([{unit_id: 1}])
        ::Katello::Rpm.expects(:import_all).with([1], true)
        run_action action
      end
    end

    context 'puppet repository' do
      it 'indexes just units sattisfying the filter' do
        action = create_and_plan_action(action_class,
                                        id: puppet_repository.id, filter: { name: 'cheetah' })
        ::Katello::Repository.any_instance.expects(:unit_search).
            with(type_ids: ['puppet_module'], filters: { 'name' => 'cheetah' }).returns([{unit_id: 1}])
        ::Katello::PuppetModule.expects(:index_puppet_modules).with([1])
        run_action action
      end
    end
  end

  class RemovePuppetModulesTest < TestBase
    let(:action_class) { ::Actions::ElasticSearch::Repository::RemovePuppetModules }

    it 'calls remove_indexed_repoid' do
      action = create_and_plan_action(action_class, uuids: [1, 2, 3], pulp_id: 'repo-6')
      ::Katello::PuppetModule.expects(:remove_indexed_repoid).with([1, 2, 3], 'repo-6')
      run_action action
    end
  end
end
