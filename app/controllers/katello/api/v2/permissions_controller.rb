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
class Api::V2::PermissionsController < Api::V1::PermissionsController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
    api_base_url "#{Katello.config.url_prefix}/api"
  end

  api :POST, "/roles/:role_id/permissions", N_("Create a roles permission")
  param :permission, Hash, :required => true do
    param :description, String, :allow_nil => true
    param :name, String, :required => true
    param :organization_id, :identifier
    param :tags, Array, :desc => N_("array of tag ids")
    param :type, String, :desc => N_("name of a resource or 'all'"), :required => true
    param :verbs, Array, :desc => N_("array of permission verbs")
    param :all_tags, :bool, :desc => N_("True if the permission should use all tags")
    param :all_verbs, :bool, :desc => N_("True if the permission should use all verbs")
  end
  def create
    perm_attrs = params[:permission].permit(:name, :description, :organization_id, :type)
    perm_attrs.merge!(
        :role          => @role,
        :organization  => @organization,
        :all_tags      => (params[:all_tags].to_bool if params[:all_tags]),
        :all_verbs     => (params[:all_verbs].to_bool if params[:all_verbs]),
        :verb_values   => perm_attrs[:verbs] || [],
        :tag_values    => perm_attrs[:tags] || [],
        :resource_type => ResourceType.find_or_create_by_name(perm_attrs[:type])
    )

    if perm_attrs[:type] == "all"
      perm_attrs[:all_tags]  = true
      perm_attrs[:all_verbs] = true
    end

    @permission = Permission.create!(perm_attrs)
    respond
  end

end
end
