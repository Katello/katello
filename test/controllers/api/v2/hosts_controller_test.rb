require 'katello_test_helper'

class Api::V2::HostsControllerTest < ActionController::TestCase
  def setup
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
  end

  def models
    @content_view = katello_content_views(:acme_default)
    @environment = katello_environments(:library)
    @dev = katello_environments(:dev)
    @cv2 = katello_content_views(:library_view_no_version)
    @cv3 = katello_content_views(:library_dev_staging_view)
    @cv4 = katello_content_views(:library_dev_view)
    @host = FactoryBot.create(:host, :with_operatingsystem)
  end

  def host_index_and_show(host)
    get :index
    assert_response :success

    get :show, params: { :id => host.id }
    assert_response :success
  end

  def host_show(host, smart_proxy)
    get :show, params: { :id => host.id }
    response = ActiveSupport::JSON.decode(@response.body)

    assert_equal smart_proxy.id, response["content_facet_attributes"]["content_source_id"]
    assert_response :success
  end

  def test_content_and_subscriptions
    host = FactoryBot.create(:host, :with_content, :with_subscription, :with_operatingsystem, :content_view => @content_view,
                              :lifecycle_environment => @environment)
    host_index_and_show(host)
  end

  def test_with_content
    host = FactoryBot.create(:host, :with_content, :with_operatingsystem, :content_view => @content_view,
                              :lifecycle_environment => @environment)
    host_index_and_show(host)
  end

  def test_no_content_view_environments
    host = FactoryBot.create(:host, :with_content, :with_subscription, :with_operatingsystem)
    assert_empty host.content_facet.content_view_environments

    host_index_and_show(host)
  end

  def test_content_facet_attributes_assigned_as_cve
    ::Host::Managed.any_instance.stubs(:update_candlepin_associations)
    host = FactoryBot.create(:host, :with_content, :with_subscription, :with_operatingsystem,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    Katello::Host::SubscriptionFacet.any_instance.expects(:backend_update_needed?).returns(false)
    orig_cves = host.content_facet.content_view_environment_ids.to_a
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_id => @cv3.id,
        :lifecycle_environment_id => @dev.id,
      },
    }, session: set_session_user
    assert_response :success
    host.content_facet.reload
    target_cve = ::Katello::ContentViewEnvironment.where(:content_view_id => @cv3.id,
      :environment_id => @dev.id).first
    assert_equal 1, host.content_facet.content_view_environment_ids.count
    refute_equal orig_cves, host.content_facet.content_view_environment_ids
    assert_equal target_cve, host.content_facet.content_view_environments.first
  end

  def test_host_contents_environments_param
    Setting[:allow_multiple_content_views] = true
    ::Host::Managed.any_instance.stubs(:update_candlepin_associations)
    host = FactoryBot.create(:host, :with_content, :with_subscription, :with_operatingsystem,
                              :content_view => @content_view, :lifecycle_environment => @environment, :organization => @environment.organization)
    Katello::Host::SubscriptionFacet.any_instance.expects(:backend_update_needed?).returns(false)
    orig_cves = host.content_facet.content_view_environment_ids.to_a
    target_cves = [::Katello::ContentViewEnvironment.where(:content_view_id => @cv4.id,
      :environment_id => @dev.id).first, ::Katello::ContentViewEnvironment.where(:content_view_id => @cv3.id,
      :environment_id => @dev.id).first]
    target_cves_ids = target_cves.map(&:id)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_environments => target_cves.map(&:label),
      },
    }, session: set_session_user
    assert_response :success
    host.content_facet.reload
    assert_equal 2, host.content_facet.content_view_environment_ids.count
    refute_equal orig_cves, host.content_facet.content_view_environment_ids
    assert_equal_arrays target_cves_ids, host.content_facet.content_view_environments.ids
  end

  def test_host_contents_cve_ids_param
    Setting[:allow_multiple_content_views] = true
    ::Host::Managed.any_instance.stubs(:update_candlepin_associations)
    host = FactoryBot.create(:host, :with_content, :with_subscription, :with_operatingsystem,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    Katello::Host::SubscriptionFacet.any_instance.expects(:backend_update_needed?).returns(false)
    orig_cves = host.content_facet.content_view_environment_ids.to_a
    target_cves_ids = [::Katello::ContentViewEnvironment.where(:content_view_id => @cv4.id,
      :environment_id => @dev.id).first, ::Katello::ContentViewEnvironment.where(:content_view_id => @cv3.id,
      :environment_id => @dev.id).first].map(&:id)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_environment_ids => target_cves_ids,
      },
    }, session: set_session_user
    assert_response :success
    host.content_facet.reload

    assert_equal 2, host.content_facet.content_view_environment_ids.count
    refute_equal orig_cves, host.content_facet.content_view_environment_ids
    assert_equal_arrays target_cves_ids, host.content_facet.content_view_environments.ids
  end

  def test_host_update_with_env_only
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :lifecycle_environment_id => @dev.id,
      },
    }, session: set_session_user
    assert_response 422
  end

  def test_host_update_with_cv_only
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_id => @cv2.id,
      },
    }, session: set_session_user
    assert_response :unprocessable_entity
  end

  def test_set_content_view_environments_with_valid_content_view_environs_param
    Katello::Host::SubscriptionFacet.any_instance.expects(:backend_update_needed?).returns(false)
    ::Host::Managed.any_instance.expects(:update_candlepin_associations)
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    ::Katello::ContentViewEnvironment.expects(:fetch_content_view_environments).returns([katello_content_view_environments(:library_default_view_environment)])
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_environments => ["Library"],
      },
    }, session: set_session_user
    assert_response :success
  end

  def test_set_content_view_environments_with_valid_ids_param
    Katello::Host::SubscriptionFacet.any_instance.expects(:backend_update_needed?).returns(false)
    ::Host::Managed.any_instance.expects(:update_candlepin_associations)
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_environment_ids => [@cv4.content_view_environments.first.id],
      },
    }, session: set_session_user
    assert_response :success
  end

  def test_set_content_view_environments_with_invalid_ids_param
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_environment_ids => ["invalid string"],
      },
    }, session: set_session_user
    assert_response :unprocessable_entity
  end

  def test_set_content_view_environments_with_invalid_content_view_environs_param
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_environments => ["invalid string"],
      },
    }, session: set_session_user
    assert_response 422
  end

  def test_host_update_with_invalid_env
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    @dev.destroy
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_id => @cv2.id,
        :lifecycle_environment_id => @dev.id,
      },
    }, session: set_session_user
    assert_response :error
  end

  def test_handle_content_view_environments_for_create
    @controller.expects(:validate_content_view_environment_params).returns([katello_content_view_environments(:library_default_view_environment)])
    @controller.expects(:set_content_view_environments).with([katello_content_view_environments(:library_default_view_environment)])

    post :create, params: {
      :host => {
        :name => "contenthost.example.com",
        :content_facet_attributes => {
          :content_view_environments => ["Library"],
        },
      },
    }, session: set_session_user
    # no assertions needed about the response, we're just making sure handle_content_view_environments_for_create is called
  end

  def test_handle_content_view_environments_for_update
    @controller.expects(:validate_content_view_environment_params).returns([katello_content_view_environments(:library_default_view_environment)])
    @controller.expects(:set_content_view_environments).with([katello_content_view_environments(:library_default_view_environment)])
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_environments => ["Library"],
      },
    }, session: set_session_user
    # no assertions needed about the response, we're just making sure handle_content_view_environments_for_update is called
  end

  def test_with_subscriptions
    host = FactoryBot.create(:host, :with_subscription, :with_operatingsystem)
    host_index_and_show(host)
  end

  def test_update_subscription_facet
    Katello::Host::SubscriptionFacet.any_instance.stubs(:backend_update_needed?).returns(false)

    Katello::Candlepin::Consumer.any_instance.stubs(:compliance_reasons).returns([])
    Katello::Candlepin::Consumer.any_instance.stubs(:virtual_host).returns(nil)
    Katello::Candlepin::Consumer.any_instance.stubs(:virtual_guests).returns([])
    Katello::Candlepin::Consumer.any_instance.stubs(:installed_products).returns([])

    host = FactoryBot.create(:host, :with_subscription, :with_operatingsystem)
    host.subscription_facet.update!(:service_level => 'Premium',
                                               :installed_products_attributes => [{:product_name => 'foo', :version => '6', :product_id => '69'}])

    put :update, params: { :id => host.id, :subscription_facet_attributes => {:service_level => 'Standard'} }

    assert_response :success

    assert_equal 'Standard', host.reload.subscription_facet.reload.service_level
    assert_equal 'foo', host.subscription_facet.installed_products.first.name
  end

  def test_with_smartproxy
    smart_proxy = FactoryBot.create(:smart_proxy, :with_pulp3)
    host = FactoryBot.create(:host, :with_content, :with_subscription, :with_operatingsystem, :content_view => @content_view,
                              :lifecycle_environment => @environment, :content_source => smart_proxy)
    host_show(host, smart_proxy)
  end

  def test_create_with_permitted_attributes
    cf_attrs = {:content_view_id => @content_view.id, :lifecycle_environment_id => @environment.id}
    sf_attrs = {:purpose_role => "MyRole"}
    attrs = @host.clone.attributes.merge("name" => "contenthost.example.com", "content_facet_attributes" => cf_attrs, "subscription_facet_attributes" => sf_attrs).compact!

    assert_difference('Host.unscoped.count') do
      post :create, params: attrs
      assert_response :success
    end
  end

  def test_create_with_unpermitted_attributes
    cf_attrs = {:content_view_id => @content_view.id,
                :lifecycle_environment_id => @environment.id,
                :uuid => "thisshouldntbeabletobesetbyuser",
               }
    attrs = @host.clone.attributes.merge("name" => "contenthost1.example.com", "content_facet_attributes" => cf_attrs).compact!

    post :create, params: attrs
    assert_response :success # the uuid is simply filtered out which allows the host to be still saved
    refute Katello::Host::ContentFacet.where(:uuid => cf_attrs[:uuid]).exists?
  end
end
