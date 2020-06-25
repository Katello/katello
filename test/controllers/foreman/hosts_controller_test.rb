require 'katello_test_helper'

class HostsControllerTest < ActionController::TestCase
  def permissions
    @sync_permission = :sync_products
  end

  def models
    @library = katello_environments(:library)
    @library_dev_staging_view = katello_content_views(:library_dev_staging_view)
  end

  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
    permissions
  end

  test 'cannot update registered host organization' do
    @request.env['HTTP_REFERER'] = hosts_path
    host = Host.find_by(name: "host1.example.com")
    dest_org_id = ::Organization.find_by(name: "Organization 1").id
    post :update_multiple_organization, params: { host_ids: [host.id],
                                                  organization: { id: dest_org_id, optimistic_import: "yes" } }
    assert_redirected_to :controller => :hosts, :action => :index
    assert_not_equal dest_org_id, host.organization_id
    assert_equal "Unregister host host1.example.com before assigning an organization", flash[:error]
  end

  test 'puppet environment for content_view' do
    get :puppet_environment_for_content_view, params: { :content_view_id => @library_dev_staging_view.id, :lifecycle_environment_id => @library.id }

    assert_response :success
  end

  test 'empty content facet parameters are removed' do
    post :create, params: { :host => {
      :name => 'test_content',
      :content_facet_attributes => {
        :lifecycle_environment_id => "",
        :content_source_id => ""
      }
    } }, session: set_session_user
    assert_empty assigns('host').content_facet
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
      get :content_hosts, params: { :format => 'csv', :organization_id => @host.organization_id }
      assert_equal "text/csv; charset=utf-8", response.headers["Content-Type"]
      assert_equal "no-cache", response.headers["Cache-Control"]
      assert_equal "attachment; filename=\"hosts-#{Date.today}.csv\"",
        response.headers["Content-Disposition"]
      buf = response.stream.instance_variable_get(:@buf)
      assert buf.is_a? Enumerator
      assert_equal "Name,Subscription Status,Installable Updates - Security,Installable Updates - Bug \
Fixes,Installable Updates - Enhancements,Installable Updates - Package Count,OS,Environment,\
Content View,Registered,Last Checkin\n",
        buf.next
      assert_equal 3, buf.count
    end

    def test_csv_export_search
      get :content_hosts, params: { :format => 'csv', :organization_id => @host.organization_id, :search => "name = #{@host.name}" }
      buf = response.stream.instance_variable_get(:@buf)
      assert_equal 2, buf.count
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
      assert_redirected_to hosts_url
    end

    test 'shows an error when host can not be destroyed' do
      ::Katello::RegistrationManager.stubs(:unregister_host).returns(false)
      delete :destroy, params: { :id => host.name }
      assert_not_nil flash[:error]
      assert_redirected_to host_path(host)
    end
  end
end
