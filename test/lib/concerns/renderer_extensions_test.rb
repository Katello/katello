require 'katello_test_helper'
require 'foreman/renderer/scope/provisioning'

module Katello
  class RendererExtensionsTest < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:rhel_6_x86_64)
      @host = hosts(:one)
      @host.content_facet.content_source = smart_proxies(:one)
      @host.operatingsystem = operatingsystems(:redhat)
      @host.content_facet.kickstart_repository = @repo
      @host.content_facet.content_view = @repo.content_view

      @hostgroup = ::Hostgroup.new
      @hostgroup.content_source = smart_proxies(:one)
      @hostgroup.operatingsystem = operatingsystems(:redhat)
      @hostgroup.kickstart_repository = @repo
      @hostgroup.content_view = @repo.content_view
    end

    def test_render_host
      scope = ::Foreman::Renderer::Scope::Provisioning.new(host: @host, source: Template.first)

      assert_include scope.allowed_variables.keys, :mediapath
      assert_include scope.allowed_variables[:mediapath], @repo.relative_path
    end

    def test_render_hostgroup
      scope = ::Foreman::Renderer::Scope::Provisioning.new(host: @hostgroup, source: Template.first)

      assert_include scope.allowed_variables.keys, :mediapath
      assert_include scope.allowed_variables[:mediapath], @repo.relative_path
    end
  end
end
