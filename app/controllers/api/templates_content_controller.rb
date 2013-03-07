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

class Api::TemplatesContentController < Api::ApiController

  resource_description do
    param :template_id, :number, :desc => "template numeric identifier", :required => true
    description "Provides interface to the template content."
  end

  before_filter :find_template

  before_filter :authorize

  def rules
    manage_test = lambda{SystemTemplate.manageable?(@template.environment.organization)}
    {
      #:add_product => manage_test,
      #:remove_product => manage_test,
      :add_package => manage_test,
      :remove_package => manage_test,
      :add_parameter => manage_test,
      :remove_parameter => manage_test,
      :add_package_group => manage_test,
      :remove_package_group => manage_test,
      :add_package_group_category => manage_test,
      :remove_package_group_category => manage_test,
      :add_distribution => manage_test,
      :remove_distribution => manage_test,
      :add_repo => manage_test,
      :remove_repo => manage_test
    }
  end

  # adding a products reults in an unusable tempalte bz 799149
  #def add_product
  #  @template.add_product_by_cpid(params[:id])
  #  @template.save!
  #  render :text => _("Added product '%s'") % params[:id], :status => 200
  #end
  #
  #def remove_product
  #  @template.remove_product_by_cpid(params[:id])
  #  @template.save!
  #  render :text => _("Removed product '%s'") % params[:id], :status => 200
  #end

  api :POST, "/templates/:template_id/packages", "Add a package"
  param :name, :identifier, :desc => "package identifier", :required => true
  def add_package
    @template.add_package(params[:name])
    @template.save!
    render :text => _("Added package '%s'") % params[:name], :status => 200
  end

  api :DELETE, "/templates/:template_id/packages/:id", "Remove a package"
  param :id, :identifier, :desc => "package identifier", :required => true
  def remove_package
    @template.remove_package(params[:id])
    @template.save!
    render :text => _("Removed package '%s'") % params[:id], :status => 200
  end

  api :POST, "/templates/:template_id/parameters", "Set parameter value"
  param :name, :identifier, :desc => "parameter identifier", :required => true
  param :value, String, :desc => "parameter value", :required => true
  def add_parameter
    @template.set_parameter(params[:name], params[:value])
    @template.save!
    render :text => _("Parameter '%{name}': '%{value}' was set") % {:name => params[:name], :value => params[:value]}, :status => 200
  end

  api :DELETE, "/templates/:template_id/parameters/:id", "Remove parameter"
  param :id, :identifier, :desc => "parameter identifier", :required => true
  def remove_parameter
    @template.remove_parameter(params[:id])
    @template.save!
    render :text => _("Removed parameter '%s'") % params[:id], :status => 200
  end

  api :POST, "/templates/:template_id/package_groups", "Add package group"
  param :name, :identifier, :desc => "package group identifier", :required => true
  def add_package_group
    @template.add_package_group(params[:name])
    @template.save!
    render :text => _("Added package group '%s'") % params[:name]
  end

  api :DELETE, "/templates/:template_id/package_groups/:id", "Remove package group"
  param :id, :identifier, :desc => "package group identifier", :required => true
  def remove_package_group
    @template.remove_package_group(params[:id])
    @template.save!
    render :text => _("Removed package group '%s'") % params[:id]
  end

  api :POST, "/templates/:template_id/package_group_categories", "Add package group category"
  param :name, :identifier, :desc => "package group category identifier", :required => true
  def add_package_group_category
    @template.add_pg_category(params[:name])
    @template.save!
    render :text => _("Added package group category '%s'") % params[:name]
  end

  api :DELETE, "/templates/:template_id/package_group_categories/:id", "Remove package group category"
  param :id, :identifier, :desc => "package group category identifier", :required => true
  def remove_package_group_category
    @template.remove_pg_category(params[:id])
    @template.save!
    render :text => _("Removed package group category '%s'") % params[:id]
  end

  api :POST, "/templates/:template_id/distributions", "Add distribution"
  param :id, :identifier, :desc => "distribution identifier", :required => true
  def add_distribution
    @template.add_distribution(params[:id])
    @template.save!
    render :text => _("Added distribution '%s'") % params[:id]
  end

  api :DELETE, "/templates/:template_id/distributions/:id", "Remove distribution"
  param :id, :identifier, :desc => "distribution identifier", :required => true
  def remove_distribution
    @template.remove_distribution(params[:id])
    @template.save!
    render :text => _("Removed distribution '%s'") % params[:id]
  end

  api :POST, "/templates/:template_id/repositories", "Add repository"
  param :id, :number, :desc => "repository numeric identifier", :required => true
  def add_repo
    @template.add_repo(params[:id])
    @template.save!
    render :text => _("Added repository '%s'") % params[:id], :status => 200
  end

  api :DELETE, "/templates/:template_id/repositories/:id", "Remove repository"
  param :id, :number, :desc => "repository numeric identifier", :required => true
  def remove_repo
    @template.remove_repo(params[:id])
    @template.save!
    render :text => _("Removed repository '%s'") % params[:id], :status => 200
  end

  private

  def find_template
    @template = SystemTemplate.find(params[:template_id])
    raise HttpErrors::NotFound, _("Couldn't find template '%s'") % params[:template_id] if @template.nil?
    raise HttpErrors::BadRequest, _("Templates can be updated only in the '%s' environment") % "Library" if not @template.environment.library?
    @template
  end

end
