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

class Api::Foreman::ConfigTemplatesController < Api::Foreman::SimpleCrudController

  def rules
    superadmin_test = lambda { current_user.has_superadmin_role? }
    super.merge :revision => superadmin_test, :build_pxe_default => superadmin_test
  end

  self.foreman_model = ::Foreman::ConfigTemplate

  def_param_group :config_template do
    param :config_template, Hash, :action_aware => true, :required => true do
      param :name, String, :required => true, :desc => "template name"
      param :template, [String, File], :required => true
      param :snippet, :bool
      param :audit_comment, String
      param :template_kind_id, :number, :desc => "not relevant for snippet"
      param :template_combinations_attributes, Array, :desc => "Array of template combinations (hostgroup_id, environment_id)"
    end
  end

  api :GET, "/config_templates/", "List templates"
  param :search, String, :desc => "filter results"
  param :order, String, :desc => "sort results"
  def index
    super params.slice('order', 'search')
  end

  api :GET, "/config_templates/:id", "Show template details"
  def show
    super
  end

  api :POST, "/config_templates/", "Create a template"
  param_group :config_template
  def create
    super
  end

  api :PUT, "/config_templates/:id", "Update a template"
  param_group :config_template
  def update
    super
  end

  api :DELETE, "/config_templates/:id", "Delete a template"
  def destroy
    super
  end

  api :GET, "/config_templates/revision"
  param :version, String, :desc => "template version"
  def revision
    render :json => foreman_model.revision(params[:version])
  end

  api :GET, "/config_templates/build_pxe_default", "Change the default PXE menu on all configured TFTP servers"
  def build_pxe_default
    render :json => foreman_model.build_pxe_default
  end
end
