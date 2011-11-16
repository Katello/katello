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
  before_filter :find_template, :only => [:show, :update, :destroy, :promote, :export]

  # TODO: define authorization rules
  skip_before_filter :authorize

  def index
    if @environment.nil?
      tpls = SystemTemplate.where(params.slice(:name))
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

    clones = @template.get_clones
    @template.attributes = params[:template].slice(:name, :parent_id, :description)
    @template.save!
    if params[:template].has_key?(:name)
      clones.each do |tpl|
        tpl.attributes = params[:template].slice(:name)
        tpl.save!
      end
    end

    render :json => @template
  end

  def destroy
    @template.destroy
    render :text => _("Deleted system template '#{@template.name}'"), :status => 200
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
    raise HttpErrors::BadRequest, _("Cannot export templates form the Locker environment.") if @template.environment.locker?

    respond_to do |format|
      format.tdl { render(:text => @template.export_as_tdl, :content_type => Mime::TDL) and return }
      format.json { render :text => @template.export_as_json }
    end
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
