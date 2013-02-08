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
  before_filter :find_custom_info, :only => :update
  before_filter :authorize


  def rules
    edit_custom_info = lambda { @informable.editable? }
    view_custom_info = lambda { @informable.readable? }

    {
        :update => edit_custom_info
    }
  end

  def update
    keyname = params[:keyname]
    CustomInfo._update(@single_custom_info, params[:custom_info][keyname])
    notify.success _("%{object_type} '%{name}' was updated") % {:object_type => @informable.class.class_name, :name => @informable.name}

    informable_class = params[:informable_type].classify.constantize
    unless search_validate(informable_class, @informable.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % @informable["name"], :asynchronous => false
    end

    respond_to do |format|
      format.html {
        render :text => @single_custom_info.value
      }
      format.js
    end
  end

  private

  def find_informable
    @informable = CustomInfo._find_informable(params[:informable_type], params[:informable_id])
  end

  def find_custom_info
    @single_custom_info = CustomInfo._find(@informable, params[:keyname])
  end

end
