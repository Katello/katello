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
class RepositoriesController < Katello::ApplicationController
  include KatelloUrlHelper

  respond_to :html, :js

  before_filter :authorize
  before_filter :find_repository

  def rules
    org_edit = lambda{current_organization.redhat_manageable?}
    {
      :enable_repo => org_edit
    }
  end

  def enable_repo
    @repository.enabled = params[:repo] == "1"
    @repository.save!
    product_content = @repository.product.product_content_by_id(@repository.content_id)
    render :json => {:id => @repository.id, :can_disable_repo_set => product_content.can_disable?}
  end

  protected

  def find_repository
    @repository = Repository.find(params[:id])
  end
end
end
