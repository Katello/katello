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

class Api::ChangesetsContentController < Api::ApiController

  before_filter :find_changeset!
  before_filter :authorize

  def rules
    manage_perm = lambda { @changeset.environment.changesets_manageable? }
    { :add_product         => manage_perm,
      :remove_product      => manage_perm,
      :add_package         => manage_perm,
      :remove_package      => manage_perm,
      :add_erratum         => manage_perm,
      :remove_erratum      => manage_perm,
      :add_repo            => manage_perm,
      :remove_repo         => manage_perm,
      :add_template        => manage_perm,
      :remove_template     => manage_perm,
      :add_distribution    => manage_perm,
      :remove_distribution => manage_perm,
    }
  end

  def add_product
    product = Product.find_by_cp_id!(params[:product_id])
    @changeset.add_product! product
    render :text => _("Added product '#{product.name}'"), :status => 200
  end

  def remove_product
    product = Product.find_by_cp_id!(params[:id])
    render_after_removal @changeset.remove_product!(product),
                         :success   => _("Removed product '#{params[:id]}'"),
                         :not_found => _("Product #{params[:id]} not found in the changeset.")
  end

  def add_package
    product = Product.find_by_cp_id!(params[:product_id])
    @changeset.add_package!(params[:name], product)
    render :text => _("Added package '#{params[:name]}'"), :status => 200
  end

  def remove_package
    product = Product.find_by_cp_id!(params[:product_id])
    render_after_removal @changeset.remove_package!(params[:id], product),
                         :success   => _("Removed package '#{params[:id]}'"),
                         :not_found => _("Package '#{params[:id]}' not found in the changeset")
  end

  def add_erratum
    product = Product.find_by_cp_id!(params[:product_id])
    @changeset.add_erratum!(params[:erratum_id], product)
    render :text => _("Added erratum '#{params[:erratum_id]}'"), :status => 200
  end

  def remove_erratum
    product = Product.find_by_cp_id!(params[:product_id])
    render_after_removal @changeset.remove_erratum!(params[:id], product),
                         :success   => _("Removed erratum '#{params[:id]}'"),
                         :not_found => _("Erratum '#{params[:id]}' not found in the changeset")
  end

  def add_repo
    repository = Repository.find(params[:repository_id])
    @changeset.add_repository!(repository)
    render :text => _("Added repository '#{repository.name}'"), :status => 200
  end

  def remove_repo
    repository = Repository.find(params[:id])
    render_after_removal @changeset.remove_repository!(repository),
                         :success   => _("Removed repository'#{params[:id]}'"),
                         :not_found => _("Repository '#{params[:id]}' not found in the changeset")
  end

  def add_template
    template = SystemTemplate.find(params[:template_id])
    @changeset.add_template!(template)
    render :text => _("Added template '#{template.name}'"), :status => 200
  end

  def remove_template
    template = SystemTemplate.find(params[:id])
    render_after_removal @changeset.remove_template!(template),
                         :success   => _("Removed template '#{params[:id]}'"),
                         :not_found => _("Template '#{params[:id]}' not found in the changeset")
  end

  def add_distribution
    product = Product.find_by_cp_id!(params[:product_id])
    @changeset.add_distribution!(params[:distribution_id], product)
    render :text => _("Added distribution '#{params[:distribution_id]}'")
  end

  def remove_distribution
    product = Product.find_by_cp_id!(params[:product_id])
    render_after_removal @changeset.remove_distribution!(params[:id], product),
                         :success   => _("Removed distribution '#{params[:id]}'"),
                         :not_found => _("Distribution '#{params[:id]}' not found in the changeset")
  end

  private

  def find_changeset!
    @changeset = Changeset.find_by_id(params[:changeset_id]) or
        raise HttpErrors::NotFound, _("Couldn't find changeset '#{params[:changeset_id]}'")
  end

  def render_after_removal(removed_objects, options = { })
    render(unless removed_objects.blank?
             { :text => (options[:success] or raise ArgumentError), :status => 200 }
           else
             { :text => (options[:not_found] or raise ArgumentError), :status => 200 }
           end)
  end

end
