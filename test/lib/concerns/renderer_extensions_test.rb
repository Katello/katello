require 'katello_test_helper'

module Katello
  class RendererExtensionsTest < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:rhel_6_x86_64)
      @host = hosts(:one)
      @host.content_facet.content_source = smart_proxies(:one)
      @host.content_facet.content_source.lifecycle_environments << katello_environments(:library)
      @host.operatingsystem = operatingsystems(:redhat)
      @host.content_facet.kickstart_repository = @repo
      cvenv = Katello::ContentViewEnvironment.find_by_cv_and_lce!(
        @repo.content_view.id,
        katello_environments(:library).id
      )
      @host.content_facet.content_view_environments = [cvenv]
      cvenv = Katello::ContentViewEnvironment.find_by_cv_and_lce!(
        @repo.content_view.id,
        katello_environments(:library).id
      )
      @hostgroup = ::Hostgroup.new(:content_view_environment_id => cvenv.id)
      @hostgroup.content_source = smart_proxies(:one)
      @hostgroup.operatingsystem = operatingsystems(:redhat)
      @hostgroup.kickstart_repository = @repo
    end

    def test_render_host
      scope = ::Foreman::Renderer::Scope::Provisioning.new(host: @host, source: Template.first)

      assert_include scope.allowed_variables.keys, :mediapath
      assert_include scope.allowed_variables[:mediapath], @repo.relative_path
    end

    def test_render_hostgroup
      ::Host::Managed.any_instance.stubs(:update_candlepin_associations)
      scope = ::Foreman::Renderer::Scope::Provisioning.new(host: @hostgroup, source: Template.first)

      assert_include scope.allowed_variables.keys, :mediapath
      assert_include scope.allowed_variables[:mediapath], @repo.relative_path
    end
  end
end
