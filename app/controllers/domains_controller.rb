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



class DomainsController < ApplicationController
  include AutoCompleteSearch

  before_filter :authorize

  before_filter :setup_options, :only => [:index, :items, :new, :create]
  before_filter :find_domain, :only => [:edit, :update, :destroy]

  # two pane columns and mapping for sortable fields
  #COLUMNS = {'name' => 'name_sort', 'lastCheckin' => 'lastCheckin'}

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
    @domain = Foreman::Domain.new(params[:domain])
    @domain.save!
    notify.success @domain.name + _(" created successfully.")
    render :partial => "common/list_item", :locals  => { :item => @domain, :accessor => "id", :columns => ["name"], :name => controller_display_name }
  rescue Resources::AbstractModel::Invalid => error
    notify.exception error
    render :json => @domain.errors, :status => :bad_request
  end


  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => { :domain => @domain, :accessor => "id", :editable => true}
  end

  def update
    @domain.update_attributes!(params[:domain])
    notify.success _("Domain updated successfully.")


    render :text => params[:domain].values.first || "" if not params[:domain].nil?
    render :text => "" if params[:domain].nil?
  rescue Resources::AbstractModel::Invalid => error
    notify.exception error
    render :json => @domain.errors, :status => :bad_request
  end

  def destroy
    if @domain.destroy
      notify.success _("Domain '%s' was deleted.") % @domain.name
      render :partial => "common/list_remove", :locals => { :id => params[:id], :name => controller_display_name }
    end
  end

  def index
    @domains = ::Foreman::Domain.all
  end

  def items
    render_panel_direct(::Foreman::Domain, @panel_options, params[:search], params[:offset], [:name, 'asc'], {:default_field => :name, :filter=>[]})
  end

  def setup_options
    @panel_options = {
      :title => _('Domains'),
      :col => [:name],
      :titles => [_("Name")],
      :create => _("Domain"),
      :create_label => _('+ New Domain'),
      :name => controller_display_name,
      :ajax_load  => true,
      :ajax_scroll => items_domains_path,
      :enable_create => true,
      :search_class => ::Foreman::Domain
    }

  end

  def controller_display_name
    return self.class.name.underscore.gsub("_controller", "").singularize
  end

  private

  def find_domain
    @domain = Foreman::Domain.find params[:id] if params[:id]
  end

end

