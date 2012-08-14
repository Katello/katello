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

  resource_description do
    short_description "Manipulates system template content"
    param :template_id, :id, :desc => "template numeric identifier"
    description <<-DOC
      Provides interface to the template content.
    DOC
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
  #api :POST, "/templates/:template_id/products"
  #def add_product
  #  @template.add_product_by_cpid(params[:id])
  #  @template.save!
  #  render :text => _("Added product '#{params[:id]}'"), :status => 200
  #end
  #
  #api :DELETE, "/templates/:template_id/products/:id"
  #def remove_product
  #  @template.remove_product_by_cpid(params[:id])
  #  @template.save!
  #  render :text => _("Removed product '#{params[:id]}'"), :status => 200
  #end

  api :POST, "/templates/:template_id/packages", "Add a package"
  param :name, :undef, :desc => "package name"
  def add_package
    @template.add_package(params[:name])
    @template.save!
    render :text => _("Added package '#{params[:name]}'"), :status => 200
  end

  api :DELETE, "/templates/:template_id/packages/:id", "Remove a package"
  param :id, :undef, :desc => "package name"
  def remove_package
    @template.remove_package(params[:id])
    @template.save!
    render :text => _("Removed package '#{params[:id]}'"), :status => 200
  end

  api :POST, "/templates/:template_id/parameters", "Set parameter value"
  param :name, :undef, :desc => "parameter name/key"
  param :value, :undef, :desc => "parameter value"
  def add_parameter
    @template.set_parameter(params[:name], params[:value])
    @template.save!
    render :text => _("Parameter '#{params[:name]}': '#{params[:value]}' was set"), :status => 200
  end

  api :DELETE, "/templates/:template_id/parameters/:id", "Remove parameter"
  param :id, :undef, :desc => "parameter name/key"
  def remove_parameter
    @template.remove_parameter(params[:id])
    @template.save!
    render :text => _("Removed parameter '#{params[:id]}'"), :status => 200
  end

  api :POST, "/templates/:template_id/package_groups", "Add package group"
  param :name, :undef, :desc => "new package group name"
  def add_package_group
    @template.add_package_group(params[:name])
    @template.save!
    render :text => _("Added package group '#{params[:name]}'")
  end

  api :DELETE, "/templates/:template_id/package_groups/:id", "Remove package group"
  param :id, :undef, :desc => "package group name"
  def remove_package_group
    @template.remove_package_group(params[:id])
    @template.save!
    render :text => _("Removed package group '#{params[:id]}'")
  end

  api :POST, "/templates/:template_id/package_group_categories", "Add package group category"
  param :name, :undef, :desc => "new package group category name"
  def add_package_group_category
    @template.add_pg_category(params[:name])
    @template.save!
    render :text => _("Added package group category '#{params[:name]}'")
  end

  api :DELETE, "/templates/:template_id/package_group_categories/:id", "Remove package group category"
  param :id, :undef, :desc => "package group category name"
  def remove_package_group_category
    @template.remove_pg_category(params[:id])
    @template.save!
    render :text => _("Removed package group category '#{params[:id]}'")
  end

  api :POST, "/templates/:template_id/distributions", "Add distribution"
  param :id, :identifier, :desc => "distribution identifier"
  def add_distribution
    @template.add_distribution(params[:id])
    @template.save!
    render :text => _("Added distribution '#{params[:id]}'")
  end

  api :DELETE, "/templates/:template_id/distributions/:id", "Remove distribution"
  param :id, :identifier, :desc => "distribution identifier"
  def remove_distribution
    @template.remove_distribution(params[:id])
    @template.save!
    render :text => _("Removed distribution '#{params[:id]}'")
  end

  api :POST, "/templates/:template_id/repositories", "Add repository"
  param :id, :id, :desc => "repository numeric identifier"
  def add_repo
    @template.add_repo(params[:id])
    @template.save!
    render :text => _("Added repository '#{params[:id]}'"), :status => 200
  end

  api :DELETE, "/templates/:template_id/repositories/:id", "Remove repository"
  param :id, :id, :desc => "repository numeric identifier"
  def remove_repo
    @template.remove_repo(params[:id])
    @template.save!
    render :text => _("Removed repository '#{params[:id]}'"), :status => 200
  end

  private

  def find_template
    @template = SystemTemplate.find(params[:template_id])
    raise HttpErrors::NotFound, _("Couldn't find template '#{params[:template_id]}'") if @template.nil?
    raise HttpErrors::BadRequest, _("Templates can be updated only in a Library environment") if not @template.environment.library?
    @template
  end

end
