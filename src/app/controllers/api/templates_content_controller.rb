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

require 'rest_client'

class Api::TemplatesContentController < Api::ApiController

  before_filter :find_template

  # TODO: define authorization rules
  skip_before_filter :authorize

  def add_product
    @template.add_product_by_cpid(params[:id])
    @template.save!
    render :text => _("Added product '#{params[:id]}'"), :status => 200
  end

  def remove_product
    @template.remove_product_by_cpid(params[:id])
    @template.save!
    render :text => _("Removed product '#{params[:id]}'"), :status => 200
  end

  def add_package
    @template.add_package(params[:name])
    @template.save!
    render :text => _("Added package '#{params[:name]}'"), :status => 200
  end

  def remove_package
    @template.remove_package(params[:id])
    @template.save!
    render :text => _("Removed package '#{params[:id]}'"), :status => 200
  end

  def add_parameter
    @template.set_parameter(params[:name], params[:value])
    @template.save!
    render :text => _("Parameter '#{params[:name]}': '#{params[:value]}' was set"), :status => 200
  end

  def remove_parameter
    @template.remove_parameter(params[:id])
    @template.save!
    render :text => _("Removed parameter '#{params[:id]}'"), :status => 200
  end

  def add_package_group
    @template.add_package_group(params[:name])
    @template.save!
    render :text => _("Added package group '#{params[:name]}'")
  end

  def remove_package_group
    @template.remove_package_group(params[:id])
    @template.save!
    render :text => _("Removed package group '#{params[:id]}'")
  end

  def add_package_group_category
    @template.add_pg_category(params[:name])
    @template.save!
    render :text => _("Added package group category '#{params[:name]}'")
  end

  def remove_package_group_category
    @template.remove_pg_category(params[:id])
    @template.save!
    render :text => _("Removed package group category '#{params[:id]}'")
  end

  def find_template
    @template = SystemTemplate.find(params[:template_id])
    raise HttpErrors::NotFound, _("Couldn't find template '#{params[:template_id]}'") if @template.nil?
    raise HttpErrors::BadRequest, _("Templates can be updated only in a Locker environment") if not @template.environment.locker?
    @template
  end


end
