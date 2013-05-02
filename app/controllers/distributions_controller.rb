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

class DistributionsController < ApplicationController

  before_filter :find_repository
  before_filter :find_distribution
  before_filter :authorize

  def rules
    readable = lambda{ @repo.environment.contents_readable? and @repo.product.readable? }
    {
      :show => readable,
      :filelist => readable
    }
  end

  def show
    render :partial=>"show"
  end

  def filelist
    render :partial=>"filelist"
  end

  private

  def find_repository
    @repo = Repository.find(params[:repository_id])
  end

  def find_distribution
    @distribution = Glue::Pulp::Distribution.find params[:id]
  end
end
