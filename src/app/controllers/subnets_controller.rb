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



class SubnetsController < ApplicationController

  before_filter :authorize

  before_filter :setup_options, :only => [:index, :items, :new, :create]
  before_filter :find_subnet, :only => [:edit, :update, :destroy]

  def rules
    {
      :index => lambda{true},
      :items => lambda{true},
      :new => lambda{true},
      :create => lambda{true},
      :edit => lambda{true},
      :update => lambda{true},
      :destroy => lambda{true}
    }
  end


  def new
    render :partial => "new", :layout => "tupane_layout", :locals => { }
  end

  def create
    @subnet = Foreman::Subnet.new(params[:subnet])
    @subnet.save!
    notify.success @subnet.name + _(" created successfully.")
    render :partial => "common/list_item", :locals  => { :item => @subnet, :accessor => "id", :columns => ["name"], :name => controller_display_name }
  rescue Resources::AbstractModel::Invalid => error
    notify.exception error
    render :json => @subnet.errors, :status => :bad_request
  end


  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => { :subnet => @subnet, :accessor => "id", :editable => true}
  end

  def update
    @subnet.update_attributes!(params[:subnet])
    notify.success _("Subnet updated successfully.")
    render :text => params[:subnet].values.first || ""

  rescue Resources::AbstractModel::Invalid => error
    notify.exception error
    render :json => @subnet.errors, :status => :bad_request
  end

  def destroy
    if @subnet.destroy
      notify.success _("Subnet '%s' was deleted.") % @subnet.name
      render :partial => "common/list_remove", :locals => { :id => params[:id], :name => controller_display_name }
    end
  end

  def index
    @subnets = ::Foreman::Subnet.all
  end

  def items
    render_panel_direct(::Foreman::Subnet, @panel_options, params[:search], params[:offset], [:name, 'asc'], {:default_field => :name, :filter=>[]})
  end

  def setup_options
    @panel_options = {
      :title => _('Subnets'),
      :col => [:name],
      :titles => [_("Name")],
      :create => _("Subnet"),
      :create_label => _('+ New Subnet'),
      :name => controller_display_name,
      :ajax_load  => true,
      :ajax_scroll => items_subnets_path,
      :enable_create => true,
      :search_class => ::Foreman::Subnet
    }

  end

  def controller_display_name
    return self.class.name.underscore.gsub("_controller", "").singularize
  end

  private

  def find_subnet
    @subnet = Foreman::Subnet.find params[:id] if params[:id]
  end

end
