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
