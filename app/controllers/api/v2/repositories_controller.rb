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


class Api::V2::RepositoriesController < Api::V1::RepositoriesController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def param_rules
    {
        :create => { :repository => [:name, :url, :gpg_key_name] },
        :update => { :repository => [:gpg_key_name] }
    }
  end

  def_param_group :repo do
    param :repository, Hash, :required => true, :action_aware => true do
      param :name, String, :required => true
      param :url, :undef, :required => true, :desc => "repository source url"
      param :gpg_key_name, String, :desc => "name of a gpg key that will be assigned to the new repository"
      param :enabled, :bool, :desc => "flag that enables/disables the repository"
      param :content_type, String, :desc => "type of repo (either 'yum' or 'puppet', defaults to 'yum')"
    end
  end

  api :POST, "/products/:product_id/repositories", "Create a repository"
  param :product_id, :number, :required => true, :desc => "id of a product the repository will be contained in"
  param_group :repo
  see "v1#gpg_keys#index"
  def create
    raise HttpErrors::BadRequest, _("Repository can be only created for custom provider.") unless @product.custom?

    repo_attrs = params[:repository]

    gpg = GpgKey.readable(@organization).find_by_name!(repo_attrs[:gpg_key_name]) if repo_attrs[:gpg_key_name].present?
    gpg ||= @product.gpg_key

    @repository = @product.add_repo(labelize_params(repo_attrs), repo_attrs[:name], repo_attrs[:url], 'yum', gpg)
  end

end
