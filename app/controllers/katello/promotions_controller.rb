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

module Katello
  class PromotionsController < ApplicationController

    before_filter :find_environment
    before_filter :authorize

    def rules
      show_test = lambda {
        to_ret = @environment && (@environment.contents_readable? || @environment.changesets_deletable?)
        to_ret ||=  @next_environment.changesets_readable? if @next_environment
        to_ret
      }

      content_view_test = lambda{ContentView.any_readable?(@environment.organization)}
      {
        :show => show_test,
        :content_views => content_view_test
      }
    end

    def section_id
      'contents'
    end

    def show
      access_envs = accessible_environments
      setup_environment_selector(current_organization, access_envs)

      @promotion_changesets = @next_environment.working_promotion_changesets if (@next_environment && @next_environment.changesets_readable?)
      @deletion_changesets = @environment.working_deletion_changesets if (@environment && @environment.changesets_readable?)

      @locals_hash = {
        :accessible_envs=> access_envs,
        :manage_deletion_changesets => (@environment && @environment.changesets_manageable?)? true : false,
        :manage_promotion_changesets => (@next_environment && @next_environment.changesets_manageable?)? true : false,
        :apply_promotion_changesets => (@next_environment && @next_environment.changesets_promotable?)? true : false,
        :apply_deletion_changesets => (@environment && @environment.changesets_deletable?)? true : false,
        :read_deletion_changesets => (@environment && @environment.changesets_readable?)? true : false,
        :read_promotion_changesets => (@next_environment && @next_environment.changesets_readable?)? true : false,
        :read_contents => (@environment && @environment.contents_readable?)? true: false
      }

      render :show, :locals=>@locals_hash
    end

    # AJAX Calls
    def content_views
      # render the list of content views
      view_versions = ContentViewVersion.non_default_view.promotable(@environment.organization).
          in_environment(@environment) || []

      next_env_view_version_ids = @next_environment.nil? ? [].to_set :
                                  @next_environment.content_view_versions.non_default_view.
                                  pluck("content_view_versions.id").to_set

      render :partial=>"content_views", :locals => {:environment => @environment, :content_view_versions => view_versions,
                                                    :next_env_view_version_ids => next_env_view_version_ids}
    end

    private

    def find_environment
      if current_organization
        @organization = current_organization
        @environment = KTEnvironment.where(:name=>params[:id]).where(:organization_id=>@organization.id).first if params[:id]
        @environment ||= first_env_in_path(accessible_environments, true)
        #raise Errors::SecurityViolation, _("Cannot find a readable environment.") if @environment.nil?

        @next_environment = KTEnvironment.find(params[:next_env_id]) if params[:next_env_id]
        @next_environment ||= @environment.successor if @environment
      end
    end

    def accessible_environments
      envs = KTEnvironment.content_readable(current_organization).all
      envs += KTEnvironment.changesets_readable(current_organization).all.map { |env| env.prior if env.prior }.compact
      envs.uniq
    end

  end
end
