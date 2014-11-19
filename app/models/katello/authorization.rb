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

module Katello
  module Authorization
    extend ActiveSupport::Concern

    # Dynamically define CRUD-able methods
    #   -able class methods return a scope
    #   -able? instance methods return a boolean

    included do
      actions = { :creatable => 'create',
                  :editable  => 'edit',
                  :readable  => 'view',
                  :deletable => 'destroy'}

      actions.each do |action, permission|
        unless self.class.respond_to? action
          define_singleton_method(action) do |user = User.current|
            authorized_as(user, action_permission(permission))
          end
        end

        unless respond_to? "#{action.to_s}?".to_sym
          define_method("#{action.to_s}?") do |user = User.current|
            user.can? self.class.action_permission(permission), self
          end
        end
      end
    end

    def authorized_as?(permission, user = User.current)
      user.can?(permission, self)
    end

    module ClassMethods
      def action_permission(permission)
        resource = self.respond_to?(:resource_permission) ? resource_permission : Katello::Util::Model.model_to_underscored(self)
        "#{permission}_#{resource.to_s}".to_sym
      end
    end
  end
end
