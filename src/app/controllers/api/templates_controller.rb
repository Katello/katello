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

  resource_description do
    description <<-DOC
      System templates are used to configure how a system should look,
      including which products are subscribed and what packages are installed.
      Once a system template has been created, it can be exported and used
      to create systems with the same settings.
    DOC
  end

  before_filter :find_environment, :only => [:create, :import, :index]
  before_filter :find_template, :only => [:show, :update, :destroy, :promote, :export, :validate]

  before_filter :authorize

  def rules
    read_test = lambda{ SystemTemplate.readable?(@template.environment.organization) }
    read_env_test = lambda{ @environment && SystemTemplate.readable?(@environment.organization) }
    manage_env_test = lambda{ @environment && SystemTemplate.manageable?(@environment.organization) }
    manage_test = lambda{ SystemTemplate.manageable?(@template.environment.organization) }
    {
      :index => read_env_test,
      :show => read_test,
      :create => manage_env_test,
      :update => manage_test,
      :destroy => manage_test,
      :validate => read_test,
      :import => manage_env_test,
      :export => read_test,
    }
  end


  def param_rules
    {
      :create => {:template => [:name, :description, :parent_id]},
      :update => {:template  => [:name, :description, :parent_id]}
    }
  end

  api :GET, "/environments/:environment_id/templates", "List system templates for given environment."
  param :environment_id, :number, :desc => "environment numeric identifier"
  param :name, :identifier, :desc => "system template identifier"
  def index
    tpls = @environment.system_templates.where(params.slice(:name))
    render :json => tpls.to_json
  end

  api :GET, "/templates/:id", "Show a template"
  param :id, :id, :desc => "system template numeric identifier"
  def show
    render :json => @template.to_json
  end

  api :POST, "/templates", "Create a template"
  param :environment_id, :id, :desc => "environment numeric identifier"
  param :template, Hash do
    param :description, :undef, :desc => "template description"
    param :name, :identifier, :desc => "new template name"
    param :parent_id, :id, :desc => "parent template numeric identifier"
  end
  def create
    raise HttpErrors::BadRequest, _("New templates can be created only in a Library environment") if not @environment.library?

    @template = SystemTemplate.new(params[:template])
    @template.environment = @environment
    @template.save!

    render :json => @template.to_json
  end

  api :PUT, "/templates/:id", "Update a template"
  param :id, :id, :desc => "template numeric identifier"
  param :template, Hash do
    param :description, :undef, :desc => "template new description"
    param :name, :identifier, :desc => "template new name"
  end
  def update
    raise HttpErrors::BadRequest, _("Templates can be updated only in a Library environment") if not @template.environment.library?

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

  api :DELETE, "/templates/:id", "Destroy a template"
  param :id, :id, :desc => "template numeric identifier"
  def destroy
    @template.destroy
    render :text => _("Deleted system template '#{@template.name}'"), :status => 200
  end

  api :POST, "/templates/import", "Import a template"
  param :environment_id, :id, :desc => "environment numeric identifier"
  param :template_file, :undef, :desc => "content of imported template"
  param :template, Hash do
    param :description, :undef, :desc => "template description"
    param :name, :identifier, :desc => "new template name"
    param :parent_id, :id, :desc => "parent template numeric identifier"
  end
  def import
    raise HttpErrors::BadRequest, _("New templates can be imported only into a Library environment") if not @environment.library?

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

  api :GET, "/templates/:id/validate", "Validate a template TDL"
  param :id, :id, :desc => "template numeric identifier"
  def validate
    raise HttpErrors::BadRequest, _("Cannot validate templates for the Library environment.") if @template.environment.library?

    respond_to do |format|
      format.tdl { @template.validate_tdl; render :text => 'OK' and return }
      format.json { render :text => 'OK' }
    end
  end

  api :GET, "/templates/:id/export", "Export template as TDL or JSON"
  param :id, :id, :desc => "template numeric identifier"
  def export
    raise HttpErrors::BadRequest, _("Cannot export templates for the Library environment.") if @template.environment.library?

    respond_to do |format|
      format.tdl { render(:text => @template.export_as_tdl, :content_type => Mime::TDL) and return }
      format.json { render :text => @template.export_as_json }
    end
  end

  private

  def find_environment
    @environment = KTEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    @environment
  end

  def find_template
    @template = SystemTemplate.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find template '#{params[:id]}'") if @template.nil?
    @template
  end
end
