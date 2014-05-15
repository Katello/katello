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
class RepositoriesController < Katello::ApplicationController
  include KatelloUrlHelper

  respond_to :html, :js

  before_filter :authorize
  before_filter :find_repository, :except => [:auto_complete_library]

  def rules
    read_any_test = lambda{ true }
    {
      :auto_complete_library => read_any_test
    }
  end

  def auto_complete_library
    # retrieve and return a list (array) of repo names in library that contain the 'term' that was passed in
    term = Util::Search.filter_input params[:term]
    name = 'name:' + term
    name_query = name + ' OR ' + name + '*'
    ids = Repository.readable.collect{|r| r.id}
    repos = Repository.search do
      query {string name_query}
      filter "and", [
          {:terms => {:id => ids}},
          {:terms => {:enabled => [true]}}
      ]
    end

    render :json => (repos.map do |repo|
      label = _("%{repo} (Product: %{product})") % {:repo => repo.name, :product => repo.product}
      {:id => repo.id, :label => label, :value => repo.name}
    end)
  end

  protected

  def find_repository
    @repository = Repository.find(params[:id])
  end
end
end
