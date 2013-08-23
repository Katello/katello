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

require 'securerandom'
require 'time'
require 'test_helper'
require File.expand_path('../../../lib/katello/url_constrained_cookie_store', __FILE__)

class UrlConstrainedCookieStoreTest < ActionController::IntegrationTest
  SessionKey = '_test_session'
  SessionSecret = '16a7078c778fb1e28d062c6d1a26e864'

  Verifier = ActiveSupport::MessageVerifier.new(SessionSecret, :digest => 'SHA1')
  SignedBar = Verifier.generate(:foo => "bar", :created_at => (Time.now - 2.minute),
      :session_id => SecureRandom.hex(16))

  def test_doesnt_update_expiraton_date_for_excluded_urls
    with_test_route_set(:expire_after => 1.minute, :expiration_exceptions => "/no_expiration") do
      cookies[SessionKey] = SignedBar
      get '/no_expiration'
      assert_response :success
      assert /expires=(.+)\;/ =~ headers['Set-Cookie']
      assert Time.parse($1) < Time.now
    end
  end

  def test_updates_expiraton_date
    with_test_route_set(:expire_after => 1.minute, :expiration_exceptions => "/no_expiration") do
      cookies[SessionKey] = SignedBar
      get '/with_expiration'
      assert_response :success
      assert /expires=(.+)\;/ =~ headers['Set-Cookie']
      assert Time.parse($1) > Time.now
    end
  end

  def get(path, parameters = nil, env = {})
    env["action_dispatch.secret_token"] ||= SessionSecret
    super
  end

  class TestController < ActionController::Base
    def no_expiration
      render :text => session[:session_id]
    end

    def with_expiration
      render :text => session[:session_id]
    end
  end

  def with_test_route_set(options = {})
    with_routing do |set|
      set.draw do
        match ':action', :to => ::UrlConstrainedCookieStoreTest::TestController
      end

      options = { :key => SessionKey }.merge!(options)

      @app = build_app(set) do |middleware|
        middleware.use ::Katello::UrlConstrainedCookieStore, options
        middleware.delete "ActionDispatch::ShowExceptions"
      end

      yield
    end
  end

  def build_app(routes = nil)
    RoutedRackApp.new(routes || ActionDispatch::Routing::RouteSet.new) do |middleware|
      middleware.use "ActionDispatch::ShowExceptions"
      middleware.use "ActionDispatch::Callbacks"
      middleware.use "ActionDispatch::ParamsParser"
      middleware.use "ActionDispatch::Cookies"
      middleware.use "ActionDispatch::Flash"
      middleware.use "ActionDispatch::Head"
      yield(middleware) if block_given?
    end
  end
end

class RoutedRackApp
  attr_reader :routes

  def initialize(routes, &blk)
    @routes = routes
    @stack = ActionDispatch::MiddlewareStack.new(&blk).build(@routes)
  end

  def call(env)
    @stack.call(env)
  end
end
