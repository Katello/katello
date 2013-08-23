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

module Katello::UrlConstrainedCookieStoreV30X
  # This is almost entirely based on ActionDispatch::Session::AbstractStore#call.
  # Unfortunately, there isn't a good way not to duplicate all this logic.
  def call(env)
    prepare!(env)
    response = @app.call(env)

    session_data = env[ActionDispatch::Session::AbstractStore::ENV_SESSION_KEY]
    options = env[ActionDispatch::Session::AbstractStore::ENV_SESSION_OPTIONS_KEY]

    if !session_data.is_a?(ActionDispatch::Session::AbstractStore::SessionHash) || session_data.loaded? || options[:expire_after]
      session_data.send(:load!) if session_data.is_a?(ActionDispatch::Session::AbstractStore::SessionHash) && !session_data.loaded?

      sid = options[:id] || generate_sid
      session_data = session_data.to_hash

      value = set_session(env, sid, session_data)
      return response unless value

      request = ActionDispatch::Request.new(env)
      cookie = create_cookie(request, value, options)
      set_cookie(request, cookie.merge!(options))
    end

    response
  end
end

module Katello::UrlConstrainedCookieStoreV32X
  def commit_session(env, status, headers, body)
    session = env['rack.session']
    options = env['rack.session.options']

    if options[:drop] || options[:renew]
      session_id = destroy_session(env, options[:id] || generate_sid, options)
      return [status, headers, body] unless session_id
    end

    return [status, headers, body] unless commit_session?(env, session, options)

    session.send(:load!) unless loaded_session?(session)
    session = session.to_hash
    session_id ||= options[:id] || generate_sid

    if !data = set_session(env, session_id, session, options)
      env["rack.errors"].puts("Warning! #{self.class.name} failed to save session. Content dropped.")
    elsif options[:defer] and !options[:renew]
      env["rack.errors"].puts("Defering cookie for #{session_id}") if $VERBOSE
    else
      cookie = create_cookie(ActionDispatch::Request.new(env), data, options)
      set_cookie(env, headers, cookie.merge!(options))
    end

    [status, headers, body]
  end
end

class Katello::UrlConstrainedCookieStore < ActionDispatch::Session::CookieStore
  include Katello::UrlConstrainedCookieStoreV30X if Rails::VERSION::STRING < "3.2"
  include Katello::UrlConstrainedCookieStoreV32X if Rails::VERSION::STRING >= "3.2"

  DEFAULT_OPTIONS.merge!(:expiration_exceptions => nil)

  def expiration_exceptions(options)
    exceptions = options[:expiration_exceptions] || []
    exceptions.instance_of?(Array) ? exceptions : [exceptions]
  end

  def create_cookie(request, cookie_data, options)
    cookie = Hash.new
    cookie[:value] = cookie_data
    if options[:expire_after]
      cookie[:value]['created_at'] ||= Time.now
      if expiration_exceptions(options).any? { |e| request.fullpath.include?(e) }
        cookie[:expires] = cookie[:value]['created_at'] + options[:expire_after]
      else
        cookie[:value]['created_at'] = Time.now
        cookie[:expires] = cookie[:value]['created_at'] + options[:expire_after]
      end
    end

    cookie
  end
end
