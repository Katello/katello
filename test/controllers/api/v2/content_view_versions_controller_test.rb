require "katello_test_helper"

module Katello
  class Api::V2::ContentViewVersionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @library = KTEnvironment.find(katello_environments(:library).id)
      @dev = KTEnvironment.find(katello_environments(:dev).id)
      @test = KTEnvironment.find(katello_environments(:test).id)
      @beta = KTEnvironment.find(katello_environments(:beta).id)
      @candlepin_dev = KTEnvironment.find(katello_environments(:candlepin_dev).id)
      @library_dev_staging_view = ContentView.find(katello_content_views(:library_dev_staging_view).id)
      @library_view = ContentView.find(katello_content_views(:library_view).id)
      @composite_version = ContentViewVersion.find(katello_content_view_versions(:composite_view_version_1).id)
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
      @publish_permission = :publish_content_views
      @env_promote_permission = :promote_or_remove_content_views_to_environments
      @cv_promote_permission = :promote_or_remove_content_views
      @export_permission = :export_content

      @dev_env_promote_permission = {:name => @env_promote_permission, :search => "name=\"#{@dev.name}\"" }
      @library_dev_staging_view_promote_permission = {:name => @cv_promote_permission, :search => "name=\"#{@library_dev_staging_view.name}\"" }
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
      ContentViewVersion.any_instance.stubs(:package_count).returns(0)
      ContentViewVersion.any_instance.stubs(:errata_count).returns(0)
    end

    def test_index
      get :index

      assert_response :success
    end

    def test_index_with_content_view
      get :index, params: { :content_view_id => @library_dev_staging_view.id }
      assert_response :success
      assert_template 'api/v2/content_view_versions/index'
    end

    def test_index_with_content_view_sorted
      get :index, params: { :content_view_id => @library_dev_staging_view.id, :order => 'version ASC' }
      assert_response :success
      assert_template 'api/v2/content_view_versions/index'
    end

    def test_index_with_content_view_in_environment
      expected_version = ContentViewVersion.find(katello_content_view_versions(:library_view_version_2).id)

      results = JSON.parse(get(:index, params: { :content_view_id => @library_view.id, :environment_id => @library.id }).body)
      assert_response :success
      assert_template 'api/v2/content_view_versions/index'

      assert_equal ['error', 'page', 'per_page', 'results', 'search', 'selectable', 'sort', 'subtotal', 'total'], results.keys.sort
      assert_equal 1, results['results'].size
      assert_equal expected_version.id, results['results'][0]['id']
    end

    def test_index_with_composite_id
      component = @library_dev_staging_view.versions.first
      @composite_version.components = [component]
      @composite_version.save!

      results = JSON.parse(get(:index, params: { :composite_version_id => @composite_version.id }).body)

      assert_response :success
      assert_template 'api/v2/content_view_versions/index'
      assert_equal 1, results['results'].size
      assert_equal component.id, results['results'][0]['id']
    end

    def test_index_with_content_view_by_version
      expected_version = ContentViewVersion.find(katello_content_view_versions(:library_view_version_2).id)
      results = JSON.parse(get(:index, params: { :content_view_id => @library_view.id, :version => 2 }).body)

      assert_response :success
      assert_template 'api/v2/content_view_versions/index'

      assert_equal ['error', 'page', 'per_page', 'results', 'search', 'selectable', 'sort', 'subtotal', 'total'], results.keys.sort
      assert_equal 1, results['results'].size
      assert_equal expected_version.id, results['results'][0]['id']
    end

    def test_index_with_organization_id
      cvv = katello_content_view_versions(:library_default_version)
      cvv_org2 = katello_content_view_versions(:candlepin_library_dev_cv_version)

      results = JSON.parse(get(:index, params: { organization_id: cvv.organization.id }).body)

      assert_response :success
      assert_template 'api/v2/content_view_versions/index'

      assert_equal ['error', 'page', 'per_page', 'results', 'search', 'selectable', 'sort', 'subtotal', 'total'], results.keys.sort
      assert_includes results['results'].map { |r| r['id'] }, cvv.id
      refute_includes results['results'].map { |r| r['id'] }, cvv_org2.id
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, params: { :content_view_id => @library_dev_staging_view.id }
      end
    end

    def test_show
      get :show, params: { :id => @library_dev_staging_view.versions.first.id }
      assert_response :success
      assert_template 'api/v2/content_view_versions/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, params: { :content_view_id => @library_dev_staging_view.id }
      end
    end

    def test_republish_repositories_without_force
      version = @library_dev_staging_view.versions.first
      put :republish_repositories, params: { :id => version.id }

      assert_response :success
      assert_template 'katello/api/v2/common/async'
    end

    def test_republish_repositories
      #force is deprecated and will be removed. Remove this test when that happens
      version = @library_dev_staging_view.versions.first
      @controller.expects(:async_task).with(::Actions::Katello::ContentViewVersion::RepublishRepositories, version, :force => true).returns({})
      put :republish_repositories, params: { :id => version.id, :force => true }

      assert_response :success
      assert_template 'katello/api/v2/common/async'
    end

    def test_promote
      version = @library_dev_staging_view.versions.first
      @controller.expects(:async_task).with(::Actions::Katello::ContentView::Promote, version, [@dev], false, 'trystero').returns({})
      post :promote, params: { :id => version.id, :environment_ids => [@dev.id], :description => 'trystero' }

      assert_response :success
      assert_template 'katello/api/v2/common/async'
    end

    def test_promote_multiple
      version = @library_dev_staging_view.versions.first
      assert_async_task(::Actions::Katello::ContentView::Promote) do |cv_version, environments|
        assert_equal version, cv_version
        assert_equal [@beta, @dev].map(&:id).sort, environments.map(&:id).sort
      end
      post :promote, params: { :id => version.id, :environment_ids => [@beta.id, @dev.id] }

      assert_response :success
      assert_template 'katello/api/v2/common/async'
    end

    def test_bad_promote_out_of_sequence
      version = @library_dev_staging_view.versions.first
      @controller.expects(:async_task).with(::Actions::Katello::ContentView::Promote, version, [@beta], false, nil).
          raises(::Katello::HttpErrors::BadRequest.new('Cannot promote environment out of sequence. Use force to bypass restriction.'))
      post :promote, params: { :id => version.id, :environment_ids => [@beta.id] }

      assert_response 400
    end

    def test_promote_out_of_sequence_force
      version = @library_dev_staging_view.versions.first
      @controller.expects(:async_task).with(::Actions::Katello::ContentView::Promote, version, [@beta], true, nil).returns({})
      post :promote, params: { :id => version.id, :environment_ids => [@beta.id], :force => 1 }

      assert_response :success
    end

    def test_promote_out_of_sequence_force_false
      version = @library_dev_staging_view.versions.first
      @controller.expects(:async_task).with(::Actions::Katello::ContentView::Promote, version, [@beta], false, nil).returns({})
      post :promote, params: { :id => version.id, :environment_ids => [@beta.id], :force => 0 }

      assert_response :success
    end

    def test_promote_protected
      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      diff_env = KTEnvironment.find(katello_environments(:staging).id)
      diff_env_promote_permission = {:name => @env_promote_permission, :search => "name=\"#{diff_env.name}\"" }
      diff_view_promote_permission = {:name => @cv_promote_permission, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [[@env_promote_permission, @cv_promote_permission],
                       [@dev_env_promote_permission, @library_dev_staging_view_promote_permission],
                       [@dev_env_promote_permission, @cv_promote_permission],
                       [@env_promote_permission, @library_dev_staging_view_promote_permission]
                      ]

      #ENV['test'] = 'asd'
      denied_perms = [[@view_permission, @create_permission, @update_permission, @destroy_permission]]
      assert_protected_action(:promote, allowed_perms, denied_perms) do
        post :promote, params: { :id => @library_dev_staging_view.versions.first.id, :environment_ids => [@dev.id] }
      end

      denied_perms = [[@view_permission, @create_permission, @update_permission, @destroy_permission,
                       diff_view_promote_permission, diff_env_promote_permission]]

      assert_protected_object(:promote, allowed_perms, denied_perms) do
        post :promote, params: { :id => @library_dev_staging_view.versions.first.id, :environment_ids => [@dev.id] }
      end
    end

    def test_promote_default
      view = ContentView.find(katello_content_views(:acme_default).id)
      post :promote, params: { :id => view.versions.first.id, :environment_ids => [@dev.id] }
      assert_response 400
    end

    def test_promote_out_of_sequence
      view = ContentView.find(katello_content_views(:acme_default).id)
      post :promote, params: { :id => view.versions.first.id, :environment_ids => [@dev.id] }
      assert_response 400
    end

    def test_promote_without_environment
      content_view_version = FactoryBot.create(:katello_content_view_version)
      post :promote, params: { :id => content_view_version.id }
      assert_response 400
    end

    def test_promote_outside_org
      version = @library_dev_staging_view.versions.first
      post :promote, params: { :id => version.id, :environment_ids => [@candlepin_dev.id], :force => 1, :description => 'test with param environment_id outside org' }
      assert_response 422
    end

    def test_promote_outside_org_with_ids_param
      version = @library_dev_staging_view.versions.first
      post :promote, params: { :id => version.id, :environment_ids => [@candlepin_dev.id], :force => 1, :description => 'test with param environment_ids outside org' }
      assert_response 422
    end

    def test_promote_multiple_outside_org
      ::Katello::ContentViewManager.stubs(:create_candlepin_environment).returns
      version = @library_dev_staging_view.versions.first
      post :promote, params: { :id => version.id, :environment_ids => [@beta.id, @candlepin_dev.id], :force => 1, :description => 'test with multiple environment_ids outside org' }
      assert_response 422
    end

    def test_incremental_update
      version = @library_dev_staging_view.versions.first
      errata_id = Katello::Erratum.first.pulp_id
      @controller.expects(:async_task).with(::Actions::Katello::ContentView::IncrementalUpdates,
                                            [{:content_view_version => version, :environments => [@beta]}], [],
                                            {'errata_ids' => [errata_id]}, true, [], nil).returns({})

      put :incremental_update, params: { :content_view_version_environments => [{:content_view_version_id => version.id, :environment_ids => [@beta.id]}], :add_content => {:errata_ids => [errata_id]}, :resolve_dependencies => true }

      assert_response :success
    end

    def test_incremental_update_with_deb
      version = @library_dev_staging_view.versions.first
      errata_id = Katello::Erratum.first.pulp_id
      deb_id = Katello::Deb.first.id
      @controller.expects(:async_task).with(::Actions::Katello::ContentView::IncrementalUpdates,
                                            [{:content_view_version => version, :environments => [@beta]}], [],
                                            {'errata_ids' => [errata_id], 'deb_ids' => [deb_id]}, true, [], nil).returns({})

      put :incremental_update, params: { :content_view_version_environments => [{:content_view_version_id => version.id, :environment_ids => [@beta.id]}], :add_content => {:errata_ids => [errata_id], :deb_ids => [deb_id]}, :resolve_dependencies => true }

      assert_response :success
    end

    def test_incremental_update_without_env
      version = @library_dev_staging_view.versions.first
      errata_id = Katello::Erratum.first.pulp_id
      @controller.expects(:async_task).with(::Actions::Katello::ContentView::IncrementalUpdates,
                                            [{:content_view_version => version, :environments => []}], [],
                                            {'errata_ids' => [errata_id]}, true, [], nil).returns({})

      put :incremental_update, params: { :content_view_version_environments => [{:content_view_version_id => version.id, :environment_ids => []}], :update_hosts => {:included => {:search => ''}}, :add_content => {:errata_ids => [errata_id]}, :resolve_dependencies => true }

      assert_response :success
    end

    def test_incremental_update_protected
      version = @library_dev_staging_view.versions.first
      errata_id = Katello::Erratum.first.pulp_id

      publish_permission = {:name => @publish_permission, :search => "name=\"#{version.content_view.name}\"" }
      view_promote_permission = {:name => @cv_promote_permission, :search => "name=\"#{version.content_view.name}\"" }
      environment_promote_permission = {:name => @env_promote_permission, :search => "name=\"#{@beta.name}\"" }

      allowed_perms = [[publish_permission, view_promote_permission, environment_promote_permission]]
      denied_perms =  [@view_permission, @create_permission, @update_permission, @cv_promote_permission,
                       publish_permission, view_promote_permission, environment_promote_permission]

      assert_protected_action(:incremental_update, allowed_perms, denied_perms) do
        put :incremental_update, params: { :content_view_version_environments => [{:content_view_version_id => version.id, :environment_ids => [@beta.id]}], :add_content => {:errata_ids => [errata_id], :resolve_dependencies => true} }
      end
    end

    def test_destroy_protected
      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      diff_view_destroy_permission = {:name => @destroy_permission, :search => "name=\"#{diff_view.name}\""}

      allowed_perms = [@destroy_permission]

      denied_perms = [[@view_permission, @create_permission, @update_permission, @cv_promote_permission, diff_view_destroy_permission]]
      assert_protected_object(:destroy, allowed_perms, denied_perms) do
        post :destroy, params: { :id => @library_dev_staging_view.versions.first.id }
      end

      denied_perms = [[@view_permission, @create_permission, @update_permission, @cv_promote_permission]]
      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        post :destroy, params: { :id => @library_dev_staging_view.versions.first.id }
      end
    end

    def test_update
      new_description = 'New version description.'
      put :update, params: { :id => @library_view.versions.first.id, :description => new_description }

      assert_response :success
      assert_template 'api/v2/content_view_versions/show'
      assert_equal @library_view.versions.first.history.publish.successful.first.notes, new_description
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]
      new_description = 'New version description.'

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, params: { :id => @library_view.versions.first.id, :description => new_description }
      end
    end
  end
end
