require 'katello_test_helper'

class HostsControllerTest < ActionController::TestCase
  def permissions
    @sync_permission = :sync_products
  end

  def models
    @library = katello_environments(:library)
    @library_dev_staging_view = katello_content_views(:library_dev_staging_view)
    @host = hosts(:one)
  end

  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
    permissions
  end

  test 'cannot update registered host organization' do
    destination_org = get_organization(:organization1)
    refute_equal @host.organization_id, destination_org.id

    post :update_multiple_organization, params: { host_ids: [@host.id],
                                                  organization: { id: destination_org.id, optimistic_import: "yes" } }

    refute_equal destination_org.id, @host.reload.organization_id
    assert_equal "Unregister host host1.example.com before assigning an organization", flash[:error]
  end

  test 'can update host same organization' do
    destination_org = @host.organization
    post :update_multiple_organization, params: { host_ids: [@host.id],
                                                  organization: { id: destination_org.id, optimistic_import: "yes" } }

    assert_equal '302', response.code
    assert_empty flash[:error]
  end

  test 'can update registered host location' do
    new_location = taxonomies(:location2)
    refute_equal @host.location_id, new_location.id

    post :update_multiple_location, params: { host_ids: [@host.id], location: { id: new_location.id, optimistic_import: 'yes' } }

    assert_equal '302', response.code
    assert_empty flash[:error]
    assert_equal new_location.id, @host.reload.location_id
  end

  test 'empty content facet parameters are removed' do
    orig_cves = @host.content_facet.content_view_environment_ids.to_a
    post :create, params: { :host => {
      :name => 'test-content',
      :content_facet_attributes => {
        :lifecycle_environment_id => "",
        :content_source_id => "",
      },
    } }, session: set_session_user
    assert_equal_arrays orig_cves, @host.content_facet.content_view_environment_ids
  end

  context 'csv' do
    setup do
      models
      @host = FactoryBot.create(:host, :with_content, :lifecycle_environment => @library,
                                        :content_view => @library_dev_staging_view)
      @host2 = FactoryBot.create(:host, :with_content, :organization_id => @host.organization_id,
                                       :content_view => @library_dev_staging_view,
                                       :lifecycle_environment =>  @library)
    end

    def test_csv_export
      @request.path = '/new/hosts.csv'
      get :index, params: { :format => 'csv', :search => "organization_id = #{@host.organization_id}" }

      assert_equal "text/csv; charset=utf-8", response.headers["Content-Type"]
      assert_equal "no-cache", response.headers["Cache-Control"]
      assert_equal "attachment; filename=\"hosts-#{Date.today}.csv\"", response.headers["Content-Disposition"]

      buf = response.stream.instance_variable_get(:@buf)
      header_line = buf.next

      # Verify default Katello columns are included (matching content_hosts behavior)
      assert_includes header_line, "Installable Updates - Security"
      assert_includes header_line, "Installable Updates - Bugfix"
      assert_includes header_line, "Installable Updates - Enhancement"
      assert_includes header_line, "Installable Packages - Rpm"
      assert_includes header_line, "Content View Environments"
      assert_includes header_line, "Registered"
      assert_includes header_line, "Last Checkin"

      # Count total lines (header + data rows)
      assert_equal @host.organization.hosts.count + 1, buf.to_a.size
    end

    def test_csv_export_search
      @request.path = '/new/hosts.csv'
      get :index, params: { :format => 'csv', :organization_id => @host.organization_id, :search => "name = #{@host.name}" }
      buf = response.stream.instance_variable_get(:@buf)
      assert_equal 2, buf.count
    end

    def test_index_csv_includes_katello_columns_for_new_hosts_path
      @request.path = '/new/hosts.csv'
      # Select Katello content columns that user wants to see (in UI weight order)
      User.current.table_preferences.create(
        name: 'hosts',
        columns: ['name', 'bootc_booted_image', 'rhel_lifecycle_status', 'installable_updates',
                  'last_checkin', 'content_view_environments', 'lifecycle_environment', 'content_view',
                  'content_source', 'registered_at', 'host_collections']
      )

      get :index, params: { :format => 'csv' }
      assert_response :success

      buf = response.stream.instance_variable_get(:@buf)
      header_line = buf.next

      # Verify Katello columns are included (in UI weight order)
      assert_includes header_line, "Image Type"
      assert_includes header_line, "Installable Updates - Security"
      assert_includes header_line, "Installable Updates - Bugfix"
      assert_includes header_line, "Installable Updates - Enhancement"
      assert_includes header_line, "Installable Packages - Rpm"
      assert_includes header_line, "Last Checkin"
      assert_includes header_line, "Content View Environments"
      assert_includes header_line, "Lifecycle Environment"
      assert_includes header_line, "Content View"
      assert_includes header_line, "Content Source"
      assert_includes header_line, "Registered"
      assert_includes header_line, "Host Collections"
    end

    def test_index_csv_excludes_katello_columns_for_legacy_hosts_path
      @request.path = '/hosts.csv'
      User.current.table_preferences.create(name: 'hosts', columns: ['name'])

      get :index, params: { :format => 'csv' }
      assert_response :success

      buf = response.stream.instance_variable_get(:@buf)
      header_line = buf.next

      # Verify Katello columns are NOT included
      refute_includes header_line, "Installable Updates - Security"
      refute_includes header_line, "Installable Updates - Bug Fixes"
      refute_includes header_line, "Content View Environments"
    end

    def test_csv_pagelets_conditional_on_request_path
      @request.path = '/new/hosts.csv'
      # Select Katello content columns
      User.current.table_preferences.create(name: 'hosts', columns: ['name', 'installable_updates', 'registered_at'])

      get :index, params: { :format => 'csv' }
      pagelets = @controller.send(:csv_pagelets)

      # Verify Katello pagelets are appended
      katello_keys = pagelets.map { |p| p.opts[:key] }
      assert_includes(katello_keys, :installable_updates)
      assert_includes(katello_keys, :registered_at)
    end

    def test_csv_pagelets_not_appended_for_legacy_path
      @request.path = '/hosts.csv'
      User.current.table_preferences.create(name: 'hosts', columns: ['name'])

      get :index, params: { :format => 'csv' }
      pagelets = @controller.send(:csv_pagelets)

      # Verify Katello pagelets are NOT appended
      katello_keys = pagelets.map { |p| p.opts[:key] }
      refute_includes(katello_keys, :installable_updates)
      refute_includes(katello_keys, :registered_at)
    end

    def test_csv_exports_default_katello_columns_when_no_preferences
      @request.path = '/new/hosts.csv'
      # Don't create any table preferences - user hasn't customized columns

      get :index, params: { :format => 'csv' }
      assert_response :success

      buf = response.stream.instance_variable_get(:@buf)
      header_line = buf.next

      # Verify default Katello columns are included (matching content_hosts method)
      assert_includes header_line, "Installable Updates - Security"
      assert_includes header_line, "Installable Updates - Bugfix"
      assert_includes header_line, "Installable Updates - Enhancement"
      assert_includes header_line, "Installable Packages - Rpm"
      assert_includes header_line, "Content View Environments"
      assert_includes header_line, "Registered"
      assert_includes header_line, "Last Checkin"

      # Verify non-default Katello columns are NOT included
      refute_includes(header_line, "Content Source")
      refute_includes(header_line, "Host Collections")
    end
  end

  context 'destroy with katello overrides' do
    let(:host) do
      FactoryBot.create(:host, :managed)
    end

    setup do
      @request.env['HTTP_REFERER'] = host_path(host)
    end

    test 'should destroy a host' do
      delete :destroy, params: { :id => host.name }
      assert_nil flash[:error]
      assert_not_nil flash[:success]
      assert_redirected_to new_hosts_index_page_url
    end

    test 'shows an error when host can not be destroyed' do
      ::Katello::RegistrationManager.stubs(:unregister_host).returns(false)
      delete :destroy, params: { :id => host.name }
      assert_not_nil flash[:error]
      assert_redirected_to host_path(host)
    end
  end

  test 'change content source' do
    host = FactoryBot.create(:host, :with_content, content_view: katello_environments(:library).content_views.first,
    lifecycle_environment: katello_environments(:library),
    content_source: FactoryBot.create(:smart_proxy, :with_pulp3))
    host2 = FactoryBot.create(:host)

    get :change_content_source_data, params: { host_ids: [host.id, host2.id] }
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal response['content_hosts'].first['id'], host.id
    assert_equal response['hosts_without_content'].first['id'], host2.id
  end
end
