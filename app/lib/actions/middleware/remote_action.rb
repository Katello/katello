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

module Actions
  module Middleware

    # Helpers for remote actions
    # wraps the plan/run/finalize methods to include the info about the user
    # that triggered the action.
    class RemoteAction < Dynflow::Middleware
      def plan(*args)
        pass(*args).tap do
          action.input[:remote_user] = User.current.remote_id
          action.input[:remote_cp_user] = User.current.login
        end
      end

      def run(*args)
        as_remote_user { pass(*args) }
      end

      def finalize
        as_remote_user { pass }
      end

      private

      def as_cp_user(&block)
        fail 'missing :remote_user' unless cp_user
        User.cp_config('cp-user' => cp_user, &block)
      end

      def as_pulp_user(&block)
        fail 'missing :remote_user' unless remote_user
        User.pulp_config(remote_user, &block)
      end

      def remote_user
        action.input[:remote_user]
      end

      def cp_user
        action.input[:remote_cp_user]
      end

      def as_remote_user
        as_cp_user do
          as_pulp_user do
            yield
          end
        end
      end

    end
  end
end
