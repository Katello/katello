#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

#
# In several cases we want to break chain of responsibility in MVC a bit and provide
# a safe way to access current user (and maybe few more data items). Storing it as
# a global variable (or class member) is not thread-safe. Including ThreadSession::
# UserModel in models and ThreadSession::Controller in the application controller
# allows this without any concurrent issues.
#
# Idea taken from sentinent_user rails plugin.
#
# http://github.com/bokmann/sentient_user
# http://github.com/astrails/let_my_controller_go
# http://rails-bestpractices.com/posts/47-fetch-current-user-in-models
#

module Katello
  module ThreadSession

    # include this in the User model
    module UserModel
      def self.included(base)
        base.class_eval do
          def self.current
            Thread.current[:user]
          end

          def self.current=(o)
            unless (o.nil? || o.is_a?(self) || o.class.name == 'RSpec::Mocks::Mock')
              raise(ArgumentError, "Unable to set current User, expected class '#{self}', got #{o.inspect}")
            end
            Rails.logger.debug "Setting current user thread-local variable to " + (o.is_a?(User) ? o.username : 'nil')
            Thread.current[:user] = o
          end

          # Executes given block on behalf of a different user. Example:
          #
          # User.as :admin do
          #   ...
          # end
          #
          # Use with care!
          #
          # @param [String] username to find from the database
          # @param [block] block to execute
          def self.as(username, &do_block)
            old_user = current
            self.current = User.find_by_username(username)
            do_block.call
            self.current = old_user
          end
        end
      end
    end

    # include this in the application controller
    module Controller
      def self.included(base)
        base.class_eval do
          around_filter :thread_locals
        end
      end

      def thread_locals
        u = current_user
        User.current = u
        yield
        # reset the current user just for the case
        User.current = nil
      rescue => exception
        # reset the current user just for the case
        User.current = nil
        raise
      end
    end
  end
end
