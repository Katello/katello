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

        version = ContentViewVersion.new(:content_view => view,
                                         :major => 1)
        view.add_environment(env, version)
        version.save!
        view.save!
      end
      view
    end

    def create_activation_key(attrs)
      env_id = attrs.delete(:environment_id)
      attrs[:environment] = KTEnvironment.find(env_id) if env_id
      if attrs[:environment] && !attrs[:environment].library? && !attrs[:content_view]
        cv = find_or_create_content_view(attrs[:environment])
        attrs[:content_view] = cv
      end
      ak = ActivationKey.create!(attrs)
      if block_given?
        yield ak
        ak.save!
      end
      ak
    end
  end
end
