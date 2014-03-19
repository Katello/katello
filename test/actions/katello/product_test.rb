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

    describe 'Destroy' do
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

    let( :action ) { create_action action_class }
  end

  class CreateTest < TestBase
    let( :action_class ) { ::Actions::Katello::Product::Create }
    let( :action ) { create_action action_class }

    let( :product ) do
      katello_products( :fedora )
    end
    let( :organization ) do
      build( :katello_organization, :acme_corporation, :with_library )
    end
  end

  it 'plans' do
    product.expects( :disable_auto_reindex ).returns
    product.expects( :save! ).returns( [] )
    action.stubs( :action_subject ).with( product, any_parameters )
    plan_action( action, provider, organization )
    assert_action_planed_with( action,
                               ::Actions::Candlepin::Product::SetProduct,
                               name: product.name,
                               multiplier: 1,
                               attributes: product.attrs )
    # TODO figure out how to specify the candlepin id or a placeholder
    assert_action_planed_with( action,
                               ::Actions::Candlepin::Product::SetUnlimitedSubscription,
                               owner_key: organization.label,
                               cp_id: nil )
  end

end

