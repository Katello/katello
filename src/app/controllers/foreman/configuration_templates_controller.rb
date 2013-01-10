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

class Foreman::ConfigurationTemplatesController < SimpleCRUDController
  before_filter :handle_template_upload, :only => [:create, :update]
  before_filter :handle_operatingsystem_ids, :only => [:create, :update]
  before_filter :find_resource, :only => [:edit, :update, :destroy, :show_template_combinations, :delete_template_combination, :create_template_combination]

  resource_model ::Foreman::ConfigTemplate
  list_column :name, :label=>_("Name")
  sort_by :name

  helper :foreman

  def rules
    {
        :index => lambda{true},
        :items => lambda{true},
        :new => lambda{true},
        :create => lambda{true},
        :edit => lambda{true},
        :associations => lambda{true},
        :add_association => lambda{true},
        :delete_association => lambda{true},
        :update => lambda{true},
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

  def update
    @resource.update_attributes!(params[resource_name.to_sym])
    notify.success _("%s updated successfully.") % resource_name.capitalize
    # What a HACK!
    # This handles ajax form submission during file uploads.
    # No easy way to submit just one field in a form; Need to return all of them.

    if params[resource_name.to_sym].size > 1
      render :json => params[resource_name.to_sym] || {}
    else
      render :text => params[resource_name.to_sym].values.first || ""
    end
  rescue Resources::AbstractModel::Invalid => error
    notify.exception error
    render :json => @resource.errors, :status => :bad_request
  end

  def handle_template_upload
    return unless params[:configuration_template] and (t=params[:configuration_template][:template])
    params[:configuration_template][:template] = t.read if t.respond_to?(:read)
  end

  def handle_operatingsystem_ids
    params[:configuration_template] = {:operatingsystems => []} unless params[:configuration_template]
    if (ids=params[:configuration_template].delete(:operatingsystem_ids))
      params[:configuration_template][:operatingsystems] = ids.collect {|id| {:id => id}}
    end
  end
end
