#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'models/model_spec_helper'
module OrganizationHelperMethods
  include OrchestrationHelper

  def new_test_org user=nil
    disable_org_orchestration
    suffix = Organization.count + 1
    @organization = Organization.create!(:name=>"test_organization#{suffix}", :label=> "test_organization#{suffix}_label")
    session[:current_organization_id] = @organization.id if defined? session
    return @organization
  end

  def new_test_org_model user=nil
    disable_org_orchestration
    suffix = Organization.count + 1
    @organization = Organization.create!(:name=>"test_organization#{suffix}", :label=> "test_organization#{suffix}_label")
    return @organization
  end

  def current_organization=(org)
    controller.stub!(:current_organization).and_return(org)
  end

  def create_environment(attrs)
    env = KTEnvironment.create!(attrs)
    if block_given?
      yield env
      env.save!
    end

    if !attrs[:content_view]
        find_or_create_content_view(env)
    end
    env
  end

  def find_or_create_content_view(env)
    if !env.library? && !env.default_content_view
      return env.content_views.first unless env.content_views.empty?

      count = ContentViewDefinition.count + 1
      definition = ContentViewDefinition.create!(:name => "test def #{count}", :label => "test_def_#{count}",
                                              :description => 'test description',
                                              :organization => env.organization)
      count = ContentView.count + 1
      view = ContentView.create!(:name => "test view #{count}", :label => "test_view_#{count}",
                              :organization => env.organization,
                              :content_view_definition => definition)

      version = ContentViewVersion.new(:content_view => view,
                                       :version => 1)
      version.environments << env
      version.save!
      view.save!
    end
    view
  end

  def promote_content_view(cv, from_env, to_env)
    Katello.pulp_server.extensions.repository.stub(:create).and_return({})
    Repository.any_instance.stub(:clone_contents).and_return([])
    Repository.any_instance.stub(:sync).and_return([])
    Repository.any_instance.stub(:pulp_repo_facts).and_return({:clone_ids => []})
    Glue::Event.stub(:trigger).and_return({})
    cv.promote(from_env, to_env)
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
