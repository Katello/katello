#
# Copyright 2013 Red Hat, Inc.
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
  namespace = ::Actions::Katello::System::Package

  describe namespace do
    include Dynflow::Testing

    let(:system) { mock('a_system', uuid: 'uuid').mimic!(::Katello::System) }
    let(:action_class) { raise NotImplementedError }
    let(:action) do
      action = create_action action_class
      action.stubs(:action_subject).with(system, :packages => packages = %w(vim vi))
      plan_action action, system, packages
    end

    describe 'Install' do
      let(:action_class) { namespace::Install }

      specify { assert_action_planed action, ::Actions::Pulp::Consumer::ContentInstall }
    end

    describe 'Remove' do
      let(:action_class) { namespace::Remove }

      specify { assert_action_planed action, ::Actions::Pulp::Consumer::ContentUninstall }
    end
  end
end
