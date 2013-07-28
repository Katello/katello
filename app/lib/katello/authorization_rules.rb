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

module Katello
  module AuthorizationRules
    def self.included(base)
      base.class_eval do
        before_filter :params_match
        before_filter :authorize
      end
    end
    # authorize the user for the requested action
    def authorize(ctrl = params[:controller], action = self.action_name)
      user = current_user
      raise StandardError, "Current user not set" unless user
      logger.debug "Authorizing #{current_user.username} for #{ctrl}/#{action}"

      allowed = false
      rule_set = rules.with_indifferent_access
      allowed = rule_set[action].call if Proc === rule_set[action]
      allowed = user.allowed_to? *rule_set[action] if Array === rule_set[action]
      return true if allowed
      raise Errors::SecurityViolation, "User #{current_user.username} is not allowed to access #{params[:controller]}/#{params[:action]}"
    end

    def rules
      raise Errors::SecurityViolation,"Rules not defined for  #{current_user.username} for #{params[:controller]}/#{params[:action]}"
    end

    # TODO: should be moved out of authorization module
    def params_match(ctrl = params[:controller], action = self.action_name)
      logger.debug "Checking  params  for #{ctrl}/#{action}"

      allowed = false
      rule_set = param_rules.with_indifferent_access

      return true unless rule_set[action]
      rule = rule_set[action]
      if Proc === rule
        bad_params = rule.call
      elsif Array === rule
        bad_params = check_array_params(rule, params)
      elsif Hash === rule
        bad_params = check_hash_params(rule, params)
      end
      return true if bad_params.empty?
      raise HttpErrors::UnprocessableEntity.new(build_bad_params_error_msg(bad_params, params))
    end

    def build_bad_params_error_msg(bad_params, params)
      scrubbed_params = Util::Support.scrub(Util::Support.deep_copy(params)) do |key, value|
        String === value && key.to_s.downcase =~ /password|authenticity_token/
      end
      _("Wrong/Invalid parameters sent for %{controller}/%{action}.\n Wrong Parameters: \n%{params}\n Parameters Received:\n %{all_params} ") % {:controller => params[:controller], :action => params[:action], :params => bad_params.inspect, :all_params => scrubbed_params.inspect}
    end

    def check_hash_params(rule, params)
      rule = rule.with_indifferent_access
      params = params.with_indifferent_access
      rule.keys.collect do |k|
        if params[k]
          keys = params[k].keys - rule[k].collect { |r| r.to_s }
          if keys.empty?
            nil
          else
            {k => keys}
          end
        end
      end.compact
    end

    def check_array_params(rule, params)
      (params.keys - ["_method", "controller", "action", "commit", "authenticity_token", "utf8", "search"] - rule.collect { |r| r.to_s })
    end

    def param_rules
      {}
    end

  end
end


