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

require 'util/url_matcher'

# Permission callback provider that are called before and after each HTTP call.
# It can be used for permission check (before) or creation (after).
#
# This implementation does nothing and is used when no provider is given.
#
class ResourcePermissions
  class << self
    def before_get_callback(a_path, headers={}) {}
    end

    def after_get_callback(a_path, headers={}, result='')
    end

    def before_post_callback(a_path, payload={}, headers={})
    end

    def after_post_callback(a_path, payload={}, headers={}, result='')
    end

    def before_put_callback(a_path, payload={}, headers={})
    end

    def after_put_callback(a_path, payload={}, headers={}, result='')
    end

    def before_delete_callback(a_path, headers={})
    end

    def after_delete_callback(a_path, headers={}, result='')
    end
  end
end

# Permission callback provider that are called before and after each HTTP call.
# It can be used for permission check (before) or creation (after).
#
# This is the default provider allowing implementations to define sets of checks.
#
class DefaultResourcePermissions < ResourcePermissions

  class_inheritable_accessor :url_prefix

  # arrays of pairs pattern path + action proc
  @@after_get_actions = []
  @@after_post_actions = []
  @@after_put_actions = []
  @@after_delete_actions = []
  @@before_get_actions = []
  @@before_post_actions = []
  @@before_put_actions = []
  @@before_delete_actions = []

  class << self
    def call_actions(actions, a_path, payload, result)
      matched = false
      actions.each do |regexp_action|
        pattern = regexp_action[0]
        action = regexp_action[1]
        Rails.logger.debug "Checking permission rule #{a_path} == #{url_prefix}#{pattern}"
        match = UrlMatcher.match a_path, url_prefix + pattern
        if match[0]
          if action.arity == 3
            action.call match, payload, result
          elsif action.arity == 2
            action.call match, payload
          else
            raise 'Resource permission provider callback must have 2 or 3 parameters'
          end
          matched = true
        end
      end
      matched
    end

    def before_get_callback(a_path, headers)
      was_called = call_actions @@before_get_actions, a_path, nil, nil
      Rails.logger.warn "WARNING unprotected REST call: GET #{a_path}" unless was_called
    end

    def after_get_callback(a_path, headers, result)
      call_actions @@after_get_actions, a_path, nil, result
    end

    def before_post_callback(a_path, payload, headers)
      was_called = call_actions @@before_post_actions, a_path, payload, nil
      Rails.logger.warn "WARNING unprotected REST call: POST #{a_path}" unless was_called
    end

    def after_post_callback(a_path, payload, headers, result)
      call_actions @@after_post_actions, a_path, payload, result
    end

    def before_put_callback(a_path, payload, headers)
      was_called = call_actions @@before_put_actions, a_path, payload, nil
      Rails.logger.warn "WARNING unprotected REST call: PUT #{a_path}" unless was_called
    end

    def after_put_callback(a_path, payload, headers, result)
      call_actions @@after_put_actions, a_path, payload, result
    end

    def before_delete_callback(a_path, headers)
      was_called = call_actions @@before_delete_actions, a_path, nil, nil
      Rails.logger.warn "WARNING unprotected REST call: DELETE #{a_path}" unless was_called
    end

    def after_delete_callback(a_path, headers, result)
      call_actions @@after_delete_actions, a_path, nil, result
    end

    def after_get(for_path, &action)
      @@after_get_actions << [for_path, action]
    end

    def after_post(for_path, &action)
      @@after_post_actions << [for_path, action]
    end

    def after_put(for_path, &action)
      @@after_put_actions << [for_path, action]
    end

    def after_delete(for_path, &action)
      @@after_delete_actions << [for_path, action]
    end

    def before_get(for_path, &action)
      @@before_get_actions << [for_path, action]
    end

    def before_post(for_path, &action)
      @@before_post_actions << [for_path, action]
    end

    def before_put(for_path, &action)
      @@before_put_actions << [for_path, action]
    end

    def before_delete(for_path, &action)
      @@before_delete_actions << [for_path, action]
    end
  end
end
