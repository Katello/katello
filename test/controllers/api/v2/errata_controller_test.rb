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

require "katello_test_helper"

module Katello
  class Api::V2::ErrataControllerTest < ActionController::TestCase
    def self.before_suite
      models = ["Organization", "KTEnvironment", "Erratum", "Repository", "Product", "Provider"]
      services = ["Candlepin", "Pulp", "ElasticSearch"]
      disable_glue_layers(services, models, true)
      ::Katello::Erratum.any_instance.stubs(:repositories).returns([])
      super
    end

    def models
      ::Katello::Product.any_instance.stubs(:as_json).returns([])
      @repo = Repository.find(katello_repositories(:rhel_6_x86_64))
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products

      @auth_permissions = [@read_permission]
      @unauth_permissions = [@create_permission, @update_permission, @destroy_permission, @sync_permission]
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)

      Katello::Erratum.any_instance.stubs(:systems_applicable).returns([])
      Katello::Erratum.any_instance.stubs(:systems_available).returns([])

      models
      permissions
    end

    def test_index
      get :index, :repository_id => @repo.id
      assert_response :success
      assert_template %w(katello/api/v2/errata/index)

      get :index
      assert_response :success
      assert_template %w(katello/api/v2/errata/index)

      get :index, :organization_id => @repo.organization.id
      assert_response :success
      assert_template %w(katello/api/v2/errata/index)
    end

    def test_index_with_content_view_version
      @content_view_version = ContentViewVersion.first
      ContentViewVersion.expects(:readable).returns(stub(:find_by_id => @content_view_version))

      get :index, :content_view_version_id => @content_view_version.id

      assert_response :success
      assert_template %w(katello/api/v2/errata/index)
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first
      KTEnvironment.expects(:readable).returns(stub(:find_by_id => environment))

      get :index, :environment_id => environment.id

      assert_response :success
      assert_template %w(katello/api/v2/errata/index)
    end

    def test_index_with_filters
      errata_filter = ContentViewFilter.find(katello_content_view_filters(:populated_erratum_filter))
      get :index, :content_view_filter_id => errata_filter

      package_group_filter = ContentViewFilter.find(katello_content_view_filters(:populated_package_group_filter))
      get :index, :content_view_filter_id => package_group_filter
    end

    def test_index_with_cve
      cve = katello_erratum_cves(:cve)

      get :index, :cve => cve.cve_id
      assert_response :success
      assert_template %w(katello/api/v2/errata/index)
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index, :repository_id => @repo.id
      end
    end

    def test_show
      errata = @repo.errata.first
      get :show, :repository_id => @repo.id, :id => errata.errata_id

      assert_response :success
      assert_template %w(katello/api/v2/errata/show)
    end

    def test_show_group_not_found
      errata = @repo.errata.first
      Erratum.expects(:with_uuid).once.with(errata.errata_id).returns([])
      Erratum.expects(:find_by_errata_id).returns(nil)

      get :show, :repository_id => @repo.id, :id => errata.errata_id
      assert_response 404
    end

    def test_compare
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      get :compare, :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id]
      assert_response :success
      assert_template %w(katello/api/v2/errata/compare)

      get :compare, :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id],
                    :repository_id => @lib_repo.id
      assert_response :success
      assert_template %w(katello/api/v2/errata/compare)
    end

    def test_show_protected
      errata = @repo.errata.first
      Erratum.stubs(:find).with(errata.errata_id).returns(errata)

      assert_protected_action(:show, @auth_permissions, @unauth_permissions) do
        get :show, :repository_id => @repo.id, :id => errata.errata_id
      end
    end
  end
end
