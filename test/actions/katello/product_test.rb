#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello

  describe ::Actions::Katello::Product do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      @org = FactoryGirl.build('katello_organization')
      @provider = FactoryGirl.build('katello_fedora_hosted_provider', organization: @org)
      @product = FactoryGirl.build('katello_product', provider: @provider, cp_id: 1234)
      @repository = FactoryGirl.build('katello_repository', product: @product, content_id: 'foobar')
    end

    describe 'Content Destroy' do
      let(:action_class) { ::Actions::Katello::Product::ContentDestroy }
      let(:candlepin_destroy_class) { ::Actions::Candlepin::Product::ContentDestroy }
      let(:candlepin_remove_class) { ::Actions::Candlepin::Product::ContentRemove }

      it 'plans' do
        @repository.stubs(:other_repos_with_same_product_and_content).returns([])
        @repository.stubs(:other_repos_with_same_content).returns([])

        action       = create_action action_class
        action.stubs(:action_subject).with(@repository)
        plan_action action, @repository
        assert_action_planed_with action, candlepin_remove_class, product_id: @product.cp_id,
                                  content_id: @repository.content_id
        assert_action_planed_with action, candlepin_destroy_class, content_id: @repository.content_id
      end

      it 'does not remove content if other content exists in different product' do
        repo2 = FactoryGirl.build('katello_repository', product: @product)
        @repository.stubs(:other_repos_with_same_product_and_content).returns([])
        @repository.stubs(:other_repos_with_same_content).returns([repo2])

        action       = create_action action_class
        action.stubs(:action_subject).with(@repository)
        plan_action action, @repository
        assert_action_planed action, candlepin_remove_class
        refute_action_planed action, candlepin_destroy_class
      end

      it 'does not destroy or remove content if other content exists in same product' do
        repo2 = FactoryGirl.build('katello_repository', product: @product)
        @repository.stubs(:other_repos_with_same_product_and_content).returns([repo2])
        @repository.stubs(:other_repos_with_same_content).returns([repo2])

        action       = create_action action_class
        action.stubs(:action_subject).with(@repository)
        plan_action action, @repository
        refute_action_planed action, candlepin_remove_class
        refute_action_planed action, candlepin_destroy_class
      end
    end
  end
end

module ::Actions::Katello::Product

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::Product::Create }
    let(:product) do
      katello_products(:fedora)
    end

    it 'plans' do
      product.orchestration_for = :create
      action.stubs(:action_subject).with do |subject, params|
        subject.must_equal(product)
        params[:cp_id].must_be_kind_of Dynflow::ExecutionPlan::OutputReference
        params[:cp_id].subkeys.must_equal %w[response id]
      end

      product.expects(:disable_auto_reindex!).returns
      product.expects(:save!).returns([])

      plan_action(action, product, product.organization)

      assert_action_planed_with(action,
                                ::Actions::Candlepin::Product::Create,
                                :name => product.name,
                                :multiplier => 1,
                                :attributes => [{:name => "arch", :value => "ALL"}])

      # TODO: figure out how to specify the candlepin id or a placeholder
      assert_action_planed(action, ::Actions::Candlepin::Product::CreateUnlimitedSubscription)
      assert_action_planed_with(action, ::Actions::ElasticSearch::Reindex, product)
    end
  end

  class UpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::Product::Update }
    let(:product) { katello_products(:fedora) }
    let(:action) { create_action action_class }
    let(:key) { katello_gpg_keys(:fedora_gpg_key) }

    it 'plans' do
      action.expects(:action_subject).with(product)
      plan_action action, product, :gpg_key_id => key.id
      assert_action_planed_with(action,
                                ::Actions::Katello::Product::RepositoriesGpgReset,
                                product)
      assert_action_planed_with(action,
                              ::Actions::Pulp::Repos::Update,
                              product)
      assert_action_planed action, ::Actions::ElasticSearch::Reindex
    end

    it 'raises error when validation fails' do
      ::Actions::Katello::Product::Update.any_instance.expects(:action_subject).with(product)
      proc { create_and_plan_action action_class, product, :name => '' }.must_raise(ActiveRecord::RecordInvalid)
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::Product::Destroy }
    let(:candlepin_destroy_class) { ::Actions::Candlepin::Product::Destroy }
    let(:candlepin_delete_pools_class) { ::Actions::Candlepin::Product::DeletePools }
    let(:candlepin_delete_subscriptions_class) { ::Actions::Candlepin::Product::DeleteSubscriptions }

    let(:product) do
      katello_products(:fedora)
    end

    it 'plans' do
      action.stubs(:action_subject).with do |subject, params|
        subject.must_equal(product)
      end
      product.expects(:user_deletable?).returns(true)
      default_view_repos = product.repositories.in_default_view.map(&:id)

      product.expects(:destroy!)
      product.expects(:disable_auto_reindex!)

      plan_action(action, product)

      assert_action_planed_with(action, candlepin_destroy_class, cp_id: product.cp_id)
      assert_action_planed_with(action, ::Actions::Katello::Repository::Destroy) do |repo|
        default_view_repos.include?(repo.first.id)
      end

      assert_action_planed_with(action,
                                candlepin_delete_pools_class,
                                cp_id: product.cp_id,
                                organization_label: product.organization.label)

      assert_action_planed_with(action, candlepin_delete_subscriptions_class,
                                cp_id: product.cp_id, organization_label: product.organization.label)

      assert_action_planed_with(action, ::Actions::ElasticSearch::Reindex, product)
    end

    it 'fails' do
      product.expects(:user_deletable?).returns(false)

      assert_raises(RuntimeError) do
        plan_action(action, product)
      end
    end
  end
end
