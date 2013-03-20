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

class CustomInfoController < ApplicationController

  before_filter :find_informable
  before_filter :find_custom_info, :only => [ :update, :destroy ]
  before_filter :authorize


  def rules
    edit_custom_info = lambda { @informable.editable? }
    view_custom_info = lambda { @informable.readable? }

    {
        :create => edit_custom_info,
        :update => edit_custom_info,
        :destroy => edit_custom_info
    }
  end

  def create
    keyname = params[:keyname].strip
    value = params[:value].strip
    @informable.custom_info.create!(:keyname => keyname, :value => value)
    notify.success _("%{object_type} '%{name}' was updated") %
      {:object_type => @informable.class.name, :name => @informable.name}
    info = CustomInfo.find_by_informable_keyname(@informable, keyname)
    render :json => info.to_json(:only => [:informable_type, :informable_id, :keyname, :value])
  end

  def update
    keyname = params[:keyname].strip
    @single_custom_info.update_attributes!(:value => params[:custom_info][keyname])
    notify.success _("%{object_type} '%{name}' was updated") %
      {:object_type => @informable.class.name, :name => @informable.name}

    render :text => @single_custom_info.value
  end

  def destroy
    @single_custom_info.destroy
    notify.success _("%{object_type} '%{name}' was updated") %
      {:object_type => @informable.class.name, :name => @informable.name}
    render :text => "true"
  end

  private

  def find_informable
    @informable = CustomInfo.find_informable(params[:informable_type], params[:informable_id])
  end

  def find_custom_info
    keyname = params[:keyname].strip
    @single_custom_info = CustomInfo.find_by_informable_keyname(@informable, keyname)
  end

end
