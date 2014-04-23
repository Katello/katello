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

      [::Katello::Package,
       ::Katello::Errata,
       ::Katello::PuppetModule].each do |klass|
        klass.expects(:indexed_ids_for_repo).with(repository.pulp_id).returns([1, 2, 3])
        klass.expects(:remove_indexed_repoid).with([1, 2, 3], repository.pulp_id)
      end
      run_action action
    end
  end

end
