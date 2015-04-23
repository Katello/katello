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

module Support
  module Actions
    module RemoteAction
      def stub_remote_user(admin = false)
        usr = mock('user', remote_id: 'user', login: 'user')
        usr.stubs(:admin?).returns(admin)
        usr.stubs(:location_and_child_ids).returns([])
        usr.stubs(:organization_and_child_ids).returns([])

        User.stubs(:current).returns usr
      end

      # runcible_expects(action, :extensions, :consumer, :create).with('uuid')
      # will check that pulp_extensions.consumer.create('uuid') was called in the
      # action.
      def runcible_expects(action, entry_method, *method_chain)
        method_chain = method_chain.dup
        if [:resources, :extensions].include?(entry_method)
          method_chain.unshift "pulp_#{entry_method}"
        else
          fail "Unexpected entry method: #{entry_method}"
        end
        last_method = method_chain.pop
        last_stub = method_chain.reduce(action) do |target, method|
          stub(method).tap { |next_stub| target.expects(method).returns(next_stub) }
        end
        last_stub.expects(last_method)
      end
    end
  end
end
