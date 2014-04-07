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

    before do
      stub_remote_user
    end

    let(:repository) { build(:katello_repository, id: 123) }
  end

  class ReindexTest < TestBase
    let(:action_class) { ::Actions::ElasticSearch::Reindex }

    let(:planned_action) do
      create_and_plan_action action_class, repository
    end

    it 'finalizes when resource present' do
      finalize_action planned_action do |action|
        ::Katello::Repository.expects(:find_by_id).with(123).returns(repository)
        repository.expects(:update_index)
      end
    end

    it 'finalizes when resource not present' do
      finalize_action planned_action do |action|
        ::Katello::Repository.expects(:find_by_id).with(123).returns(nil)
        ::Katello::Repository.expects(:index).returns(mock(:remove => true))
      end
    end
  end

  class Repository::IndexContentTest < TestBase
    let(:action_class) { ::Actions::ElasticSearch::Repository::IndexContent }

    let(:planned_action) do
      create_and_plan_action action_class, id: 123
    end

    it 'runs' do
      run_action planned_action do |action|
        ::Katello::Repository.expects(:find).with(123).returns(repository)
        repository.expects(:index_content)
      end
    end
  end
end
