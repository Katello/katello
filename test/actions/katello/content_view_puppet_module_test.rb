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

module ::Actions::Katello::ContentViewPuppetModule

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods
    include Support::CapsuleSupport
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewPuppetModule::Destroy }
    let(:action) { create_action action_class }

    let(:puppet_repository) { katello_repositories(:p_forge) }
    let(:puppet_module) { katello_content_view_puppet_modules(:library_view_module_by_uuid) }

    it 'plans' do
      puppet_module = ::Katello::ContentViewPuppetModule.find(katello_content_view_puppet_modules(:library_view_module_by_uuid))
      puppet_repository.stubs(:puppet_modules).returns([OpenStruct.new(:id => puppet_module.uuid,
                                                                       :repoids => [puppet_repository.pulp_id])])
      action.expects(:action_subject).with(puppet_repository)
      plan_action action, puppet_repository

      assert_nil ::Katello::ContentViewPuppetModule.find_by_id(puppet_module.id)
    end
  end
end
