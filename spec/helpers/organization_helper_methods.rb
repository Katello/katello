require File.expand_path("../models/model_spec_helper", File.dirname(__FILE__))

module Katello
  module OrganizationHelperMethods
    include OrchestrationHelper
    def setup_test_org
      disable_org_orchestration
      @organization = get_organization
      session[:current_organization_id] = @organization.id if defined? session
    end

    def current_organization=(org)
      controller.stubs(:current_organization).returns(org)
    end

    def create_environment(attrs)
      env = KTEnvironment.create!(attrs)

      unless attrs[:content_view]
        find_or_create_content_view(env)
      end
      env
    end

    def find_or_create_content_view(env)
      if !env.library? && !env.default_content_view
        return env.content_views.first unless env.content_views.empty?

        count = ContentView.count + 1
        view = ContentView.create!(:name => "test view #{count}", :label => "test_view_#{count}",
                                   :organization => env.organization)

        version = ContentViewVersion.first_or_create(:content_view => view,
                                         :major => 1)
        view.add_environment(env, version)
        version.save!
        view.save!
      end
      view
    end
  end
end
