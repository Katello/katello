# -*- coding: utf-8 -*-
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



class SimpleCRUDController < ApplicationController

  MISSING_COLUMNS_ERROR = "Please specify tupane list columns using 'list_column :col_name, _(\"col_label\"), ...' in #{self.class} definition."
  MISSING_RESOURCE_ERROR = "Please specify model class using 'resource_model ClassName' in #{self.class} definition."

  before_filter :authorize

  before_filter :setup_panel_options, :only => [:index, :items, :new, :create]
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def rules
    {}
  end

  def setup_panel_options
    @panel_options = {
      :title => "",
      :col => list_columns,
      :titles => list_labels,
      :create => "",
      :name => resource_name,
      :ajax_load  => true,
      :ajax_scroll => nil,
      :enable_create => true,
      :search_class => resource_model
    }
    @panel_options.merge! panel_options
  end

  def new
    render :partial => "new", :locals => { }
  end

  def create
    @resource = resource_model.new(params[resource_name.to_sym].delete_if {|k,v| v.blank?})
    @resource.save!
    notify.success _("'%s' created successfully.") % @resource.name
    render :partial => "common/list_item", :locals  => { :item => @resource, :accessor => "id", :columns => list_columns, :name => resource_name }
  rescue Resources::AbstractModel::Invalid => error
    notify.exception error
    render :json => @resource.errors, :status => :bad_request
  end


  def edit
    render :partial => "edit", :locals => { resource_name.to_sym => @resource, :accessor => "id", :editable => true}
  end

  def update
    @resource.update_attributes!(params[resource_name.to_sym])
    notify.success _("%s updated successfully.") % resource_name.capitalize
    render :text => params[resource_name.to_sym].values.first || ""

  rescue Resources::AbstractModel::Invalid => error
    notify.exception error
    render :json => @resource.errors, :status => :bad_request
  end

  def destroy
    if @resource.destroy
      notify.success _("'%s' was deleted.") % @resource.name
      render :partial => "common/list_remove", :locals => { :id => params[:id], :name => resource_name }
    end
  end

  def items
    render_panel_direct(
      resource_model,
      @panel_options,
      params[:search],
      params[:offset],
      [default_sort_field, 'asc'],
      { :default_field => default_sort_field, :filter=>[] }
    )
  end


  class << self
    attr_accessor :resource_model
    private :resource_model=

    def resource_model model=nil
      @resource_model = model unless model.nil?
      @resource_model
    end

    attr_accessor :list_columns
    private :list_columns=
    attr_accessor :list_labels
    private :list_labels=

    def list_column name, options
      @list_columns ||= []
      @list_columns << name.to_sym
      @list_labels ||= []
      @list_labels << (options.try(:key?, :label) ? options[:label] : nil)
    end

    attr_accessor :default_sort_field
    private :default_sort_field=

    def sort_by column
      @default_sort_field = column.to_sym unless column.nil?
      @default_sort_field
    end
  end

  def resource_model
    self.class.resource_model or
        raise ArgumentError, MISSING_RESOURCE_ERROR
  end

  def list_columns
    self.class.list_columns or
        raise ArgumentError, MISSING_COLUMNS_ERROR
  end

  def list_labels
    self.class.list_labels or
        raise ArgumentError, MISSING_COLUMNS_ERROR
  end

  def default_sort_field
    self.class.default_sort_field or list_columns.first
  end

  def resource_name
    return self.class.name.demodulize.underscore.gsub("_controller", "").singularize
  end

  private

  def find_resource
    @resource = resource_model.find params[:id] if params[:id]
    eval "@"+resource_name.downcase+"=@resource"
  end

end
