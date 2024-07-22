require 'katello_test_helper'

class HostgroupsControllerTest < ActionController::TestCase
  def models
    @library      = katello_environments(:library)
    @library_view = katello_content_views(:library_view)
  end

  def setup
    setup_controller_defaults(false, false)
    login_user(User.find(users(:admin).id))
    models
  end

  def test_new
    get :new

    assert_response :success
  end

  def test_create
    post :create, params: {
      :hostgroup => {
        :name => "foobar",
        :content_facet_attributes => {
          :content_view_id => @library_view.id,
          :lifecycle_environment_id => @library.id,
        },
      },
    }

    assert_equal 1, ::Hostgroup.unscoped.where(:name => "foobar").count
    assert_response 302
  end

  def test_create_with_ks_repo
    repo = katello_repositories(:fedora_17_x86_64)
    smart_proxy = SmartProxy.pulp_primary

    os = Redhat.find_or_create_operating_system(repo)
    arch = Architecture.where(:name => repo.distribution_arch).first_or_create!
    os.architectures << arch unless os.architectures.include?(arch)

    post :create, params: {
      :hostgroup => {
        :name => "foobar",
        :architecture_id => arch.id,
        :operatingsystem_id => os.id,
        :content_view_id => repo.content_view.id,
        :lifecycle_environment_id => repo.environment.id,
        :content_source_id => smart_proxy.id,
        :kickstart_repository_id => repo.id,
      },

    }

    assert_equal 1, ::Hostgroup.unscoped.where(:name => "foobar").count
    assert_response 302
  end
end
