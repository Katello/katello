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

module Katello
  class Api::V2::CapsuleContentController < Api::V2::ApiController

    before_filter :authenticate
    skip_before_filter :authorize

    resource_description do
      api_base_url "#{Katello.config.url_prefix}/api"
    end

    before_filter :find_capsule
    before_filter :find_environment, :only => [:add_lifecycle_environment, :remove_lifecycle_environment]

    def_param_group :lifecycle_environments do
      param :id, Integer, :desc => 'Id of the capsule', :required => true
      param :organization_id, Integer, :desc => 'Id of the organization to limit environments on'
    end

    def_param_group :update_lifecycle_environments do
      param :id, Integer, :desc => 'Id of the capsule', :required => true
      param :environment_id, Integer, :desc => 'Id of the lifecycle environment', :required => true
    end

    api :GET, '/capsules/:id/content/lifecycle_environments', 'List the lifecycle environments attached to the capsule'
    param_group :lifecycle_environments
    def lifecycle_environments
      @lifecycle_environments = capsule_content.lifecycle_environments(params[:organization_id])
    end

    api :GET, '/capsules/:id/content/available_lifecycle_environments', 'List the lifecycle environments not attached to the capsule'
    param_group :lifecycle_environments
    def available_lifecycle_environments
      @lifecycle_environments = capsule_content.available_lifecycle_environments(params[:organization_id])
      render 'katello/api/v2/capsule_content/lifecycle_environments'
    end

    api :POST, '/capsules/:id/content/lifecycle_environments', 'Add lifecycle environments to the capsule'
    param_group :update_lifecycle_environments
    def add_lifecycle_environment
      task = sync_task(::Actions::Katello::CapsuleContent::AddLifecycleEnvironment,
                       capsule_content, @environment)
      respond_for_async :resource => task
    end

    api :DELETE, '/capsules/:id/content/lifecycle_environments/:environment_id',  'Remove lifecycle environments from the capsule'
    param_group :update_lifecycle_environments
    def remove_lifecycle_environment
      task = sync_task(::Actions::Katello::CapsuleContent::RemoveLifecycleEnvironment,
                       capsule_content, @environment)
      respond_for_async :resource => task
    end

    api :POST, '/capsules/:id/content/sync',  'Synchronize the content to the capsule'
    param :id, Integer, :desc => 'Id of the capsule', :required => true
    param :environment_id, Integer, :desc => 'Id of the environment to limit the synchronization on'
    def sync
      find_environment if params[:environment_id]
      task = async_task(::Actions::Katello::CapsuleContent::Sync, capsule_content, @environment)
      respond_for_async :resource => task
    end

    protected

    def find_capsule
      # TODO: scope by authorization
      @capsule = SmartProxy.find(params[:id])
    end

    def find_environment
      # TODO: scope by authorization
      @environment = Katello::KTEnvironment.find(params[:environment_id])
    end

    def capsule_content
      CapsuleContent.new(@capsule)
    end

  end
end
