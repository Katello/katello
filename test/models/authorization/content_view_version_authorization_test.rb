require 'models/authorization/authorization_base'

module Katello
  class ContentViewVersionAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:admin).id)
    end

    def test_readable
      refute_empty ContentViewVersion.readable
    end
  end

  class ContentViewVersionAuthorizationNonAuthUserTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:restricted).id)
    end

    def test_readable
      assert_empty ContentViewVersion.readable
    end
  end

  class ContentViewVersionAuthorizationAllHostsEditableTest < AuthorizationTestBase
    def setup
      super
      @library = katello_environments(:library)
      @view =  katello_content_views(:library_dev_view)
      @host = FactoryGirl.create(:host, :with_content, :content_view => @view, :lifecycle_environment => @library)
    end

    def test_admin
      User.current = User.find(users(:admin).id)

      assert @view.version(@library).all_hosts_editable?(@library)
    end

    def test_non_admin
      User.current = User.find(users(:restricted).id)
      User.current.organizations = [@host.organization, @view.organization]
      User.current.locations = [@host.location]

      refute @view.version(@library).all_hosts_editable?(@library)
    end
  end
end
