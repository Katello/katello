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
      assert_equal "attachment; filename=\"hosts-#{Date.today}.csv\"", response.headers["Content-Disposition"]
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
end
