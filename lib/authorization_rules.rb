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

module AuthorizationRules
  def self.included(base)
    base.class_eval do
      before_filter :authorize
    end
  end
  # authorize the user for the requested action
  def authorize(ctrl = params[:controller], action = params[:action])
    user = current_user
    user = User.anonymous unless user
    logger.debug "Authorizing #{current_user.username} for #{ctrl}/#{action}"

    allowed = false
    rule_set = rules.with_indifferent_access
    puts "checking rules"
    allowed = rule_set[action].call if Proc === rule_set[action]
    allowed = user.allowed_to? *rule_set[action] if Array === rule_set[action]
    return true if allowed
    raise Errors::SecurityViolation, "User #{current_user.username} is not allowed to access #{params[:controller]}/#{params[:action]}"
  end

  def rules
    raise Errors::SecurityViolation,"Rules not defined for  #{current_user.username} for #{params[:controller]}/#{params[:action]}"
  end

end


