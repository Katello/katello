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
      User.current.remote_id =  User.current.login
      env = KTEnvironment.create!(attrs)
      if block_given?
        yield env
        env.save!
      end

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

    def publish_content_view(name, org, repos)
      Katello.pulp_server.extensions.repository.stubs(:create).returns({})
      Repository.any_instance.stubs(:clone_contents).returns([])
      ContentView.any_instance.stubs(:associate_yum_content).returns([])
      Repository.stubs(:trigger_contents_changed).returns([])
      cv = ContentView.create!(:organization => org, :name => name)
      cv.stubs(:repositories_to_publish).returns(repos)
      cv.stubs(:check_ready_to_publish!)
      cv.save!
      plan = ForemanTasks.dynflow.world.plan(::Actions::Katello::ContentView::Publish, cv)
      plan.failed_steps.each { |step| fail step.error if step.error }
      cv
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
