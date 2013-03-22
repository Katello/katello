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

class Katello::UrlConstrainedCookieStore < ActionDispatch::Session::CookieStore
  DEFAULT_OPTIONS.merge!(:expiration_exceptions => nil)

  # This is almost entirely based on ActionDispatch::Session::AbstractStore#call.
  # Unfortunately, there isn't a good way not to duplicate all this logic.
  def call(env)
    prepare!(env)
    response = @app.call(env)

    session_data = env[ENV_SESSION_KEY]
    options = env[ENV_SESSION_OPTIONS_KEY]

    if !session_data.is_a?(ActionDispatch::Session::AbstractStore::SessionHash) || session_data.loaded? || options[:expire_after]
      session_data.send(:load!) if session_data.is_a?(ActionDispatch::Session::AbstractStore::SessionHash) && !session_data.loaded?

      sid = options[:id] || generate_sid
      session_data = session_data.to_hash

      value = set_session(env, sid, session_data)
      return response unless value

      request = ActionDispatch::Request.new(env)
      cookie = { :value => value }
      unless options[:expire_after].nil?
        cookie[:value]['created_at'] ||= Time.now
        if expiration_exceptions(options).any? { |e| request.fullpath.include?(e) }
          cookie[:expires] = cookie[:value]['created_at'] + options.delete(:expire_after)
        else
          cookie[:value]['created_at'] = Time.now
          cookie[:expires] = cookie[:value]['created_at'] + options.delete(:expire_after)
        end
      end

      set_cookie(request, cookie.merge!(options))
    end

    response
  end

  def expiration_exceptions(options)
    exceptions = options.delete(:expiration_exceptions) or []
    exceptions.instance_of?(Array) ? exceptions : [exceptions]
  end
end