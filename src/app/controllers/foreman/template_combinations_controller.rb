# -*- coding: utf-8 -*-
#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Foreman::TemplateCombinationsController < SimpleCRUDController
  before_filter :find_resource, :only => [:index, :create]

  resource_model ::Foreman::ConfigTemplate
  list_column :name, :label=>_("Name")
  sort_by :name

  def rules
    {
        :index => lambda{true},
        :create => lambda{true},
        :destroy => lambda{true}
    }
  end

  def panel_options
    {
        :title => _('Configuration Templates'),
        :create => _("Configuration Template"),
        :create_label => _('+ New Configuration Template'),
        :ajax_scroll => items_configuration_templates_path,
    }
  end

  def index
    @template_combinations = Foreman::TemplateCombination.all('config_template_id' => params[:configuration_template_id])
    render :partial => "items", :layout => "tupane_layout", :locals => { resource_name.to_sym => @resource, :accessor => "id" }
  end

  def create
    template_combination = Foreman::TemplateCombination.new(
        params[:template_combination].merge('config_template_id' => params[:configuration_template_id]).delete_if {|k,v| v.blank?})
    template_combination.save!

    @template_combinations = Foreman::TemplateCombination.all('config_template_id' => params[:configuration_template_id])
    notify.success _("'%s' created successfully.") % @resource.name
    render :partial => "items", :layout => "tupane_layout", :locals => { resource_name.to_sym => @resource, :accessor => "id" }
  rescue Resources::AbstractModel::Invalid => error
    notify.exception error
    render :json => @resource.errors, :status => :bad_request
  end

  def destroy
    template_combination = Foreman::TemplateCombination.find(params[:id])
    template_combination.destroy

    @template_combinations = Foreman::TemplateCombination.all('config_template_id' => template_combination.config_template_id)
    @configuration_template = @resource = Foreman::ConfigTemplate.find(template_combination.config_template_id)
    notify.success _("Template Combination deleted successfully.")
    render :partial => "items", :layout => "tupane_layout", :locals => { resource_name.to_sym => @resource, :accessor => "id" }
  rescue Resources::AbstractModel::Invalid => error
    notify.exception error
    render :json => @resource.errors, :status => :bad_request
  end

  def resource_name
    "configuration_template"
  end

  def find_resource
    @configuration_template = @resource = Foreman::ConfigTemplate.find params[:configuration_template_id] if params[:configuration_template_id]
  end
end
