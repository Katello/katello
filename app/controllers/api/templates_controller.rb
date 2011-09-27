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

class Api::TemplatesController < Api::ApiController

  before_filter :find_environment, :only => [:create, :import]
  before_filter :try_find_environment, :only => [:index]
  before_filter :find_template, :only => [:show, :update, :update_content, :destroy, :promote, :export]

  # TODO: define authorization rules
  skip_before_filter :authorize

  def index
    if @environment.nil?
      tpls = SystemTemplate.all.where(params.slice(:name))
    else
      tpls = @environment.system_templates.where(params.slice(:name))
    end
    render :json => tpls.to_json
  end

  def show
    render :json => @template.to_json
  end

  def create
    raise HttpErrors::BadRequest, _("New templates can be created only in a Locker environment") if not @environment.locker?

    @template = SystemTemplate.new(params[:template])
    @template.environment = @environment
    @template.save!

    render :json => @template.to_json
  end

  def update
    raise HttpErrors::BadRequest, _("Templates can be updated only in a Locker environment") if not @template.environment.locker?

    params[:template].delete(:products_json)
    params[:template].delete(:packages_json)
    params[:template].delete(:errata_json)
    params[:template].delete(:parameters_json)
    params[:template].delete(:host_group_json)

    @template.update_attributes!(params[:template])
    render :json => @template
  end

  def update_content
    raise HttpErrors::BadRequest, _("Templates can be updated only in a Locker environment") if not @template.environment.locker?

    case params[:do].to_s
      when 'add_product'
        @template.add_product(params[:product])
        @template.save!
        render :text => _("Added product '#{params[:product]}'"), :status => 200 and return

      when 'remove_product'
        @template.remove_product(params[:product])
        @template.save!
        render :text => _("Removed product '#{params[:product]}'"), :status => 200 and return

      when 'add_package'
        @template.add_package(params[:package])
        @template.save!
        render :text => _("Added package '#{params[:package]}'"), :status => 200 and return

      when 'remove_package'
        @template.remove_package(params[:package])
        @template.save!
        render :text => _("Removed package '#{params[:package]}'"), :status => 200 and return

      when 'add_parameter'
        @template.parameters[params[:parameter]] = params[:value]
        @template.save!
        render :text => _("Added kickstart attribute '#{params[:attribute]}': '#{params[:value]}'"), :status => 200 and return

      when 'remove_parameter'
        @template.parameters.delete(params[:parameter])
        @template.save!
        render :text => _("Removed kickstart attribute '#{params[:attribute]}'"), :status => 200 and return

      when 'add_package_group'
        @template.add_package_group(:id => params[:package_group], :repo_id => params[:repo])
        @template.save!
        render :text => _("Added package group '%s'") % params[:package_group]

      when 'remove_package_group'
        @template.remove_package_group(:id => params[:package_group], :repo_id => params[:repo])
        @template.save!
        render :text => _("Removed package group '%s'") % params[:package_group]

      when 'add_package_group_category'
        @template.add_pg_category(:id => params[:package_group_category], :repo_id => params[:repo])
        @template.save!
        render :text => _("Added package group category '%s'") % params[:package_group_category]

      when 'remove_package_group_category'
        @template.remove_pg_category(:id => params[:package_group_category], :repo_id => params[:repo])
        @template.save!
        render :text => _("Removed package group category '%s'") % params[:package_group_category]
    end

  end

  def destroy
    @template.destroy
    render :text => _("Deleted system template '#{params[:id]}'"), :status => 200
  end

  def import
    raise HttpErrors::BadRequest, _("New templates can be imported only into a Locker environment") if not @environment.locker?

    begin
      temp_file = File.new(File.join("#{Rails.root}/tmp", "template_#{SecureRandom.hex(10)}.json"), 'w+', 0600)
      temp_file.write params[:template_file].read
    ensure
      temp_file.close
    end

    @template = SystemTemplate.new(params[:template])
    @template.environment = @environment
    @template.import File.expand_path(temp_file.path)
    @template.save!

    render :text => _("Template imported"), :status => 200
  end

  def export
    json = @template.string_export
    render :json => json
  end

  def promote
    async_job = @template.async(:organization => @template.environment.organization).promote
    render :json => async_job, :status => 202
  end

  def find_environment
    @environment = KTEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    @environment
  end

  def try_find_environment
    find_environment if not params[:environment_id].nil?
  end

  def find_template
    @template = SystemTemplate.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find template '#{params[:id]}'") if @template.nil?
    @template
  end


end
