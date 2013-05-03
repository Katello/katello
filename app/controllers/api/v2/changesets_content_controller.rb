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

class Api::V2::ChangesetsContentController < Api::V2::ApiController

  before_filter :find_changeset
  before_filter :find_content_view, :only => [:add_content_view, :remove_content_view]
  before_filter :authorize

  def rules
    manage_perm = lambda { @changeset.environment.changesets_manageable? }
    cv_perm     = lambda { @changeset.environment.changesets_manageable? && @view.promotable? }
    { :add_product         => manage_perm,
      :remove_product      => manage_perm,
      :add_package         => manage_perm,
      :remove_package      => manage_perm,
      :add_erratum         => manage_perm,
      :remove_erratum      => manage_perm,
      :add_repo            => manage_perm,
      :remove_repo         => manage_perm,
      :add_distribution    => manage_perm,
      :remove_distribution => manage_perm,
      :add_content_view    => cv_perm,
      :remove_content_view => cv_perm
    }
  end

  api :POST, "/changesets/:changeset_id/products", "Add a product to a changeset"
  param :product, Hash, :required => true do
    param :id, :number, :required => true, :desc => "id of the product that should be added"
  end
  def add_product
    product = find_product(params[:product][:id].to_s)
    @changeset.add_product! product
    respond_for_create :resource => @changeset, :template => :show
  end

  api :DELETE, "/changesets/:changeset_id/products/:product_id", "Removes a product from a changeset"
  param :changeset_id, :number
  param :product_id, :number, :required => true, :desc => "id of the product that should be removed"
  def remove_product
    product = find_product(params[:id])
    @changeset.remove_product!(product)
    respond_for_show :resource => @changeset, :template => :show
  end

  api :POST, "/changesets/:changeset_id/packages", "Add a package to a changeset"
  param :changeset_id, :number
  param :package, Hash, :required => true do
    param :name, String, :desc => "The nvrea of the package to add"
    param :product_id, :number, :desc => "id of the product which contains the package"
  end
  def add_package
    product = find_product(params[:package][:product_id])

    @changeset.add_package!(params[:package][:name], product)
    respond_for_create :resource => @changeset, :template => :show
  end

  api :DELETE, "/changesets/:changeset_id/packages/:package_id", "Remove a package from a changeset"
  param :changeset_id, :number
  param :package_id, :number, :desc => "id of the package-changeset relation"
  def remove_package
    ChangesetPackage.find(params[:id]).destroy
    respond_for_show :resource => @changeset, :template => :show
  end

  api :POST, "/changesets/:changeset_id/errata", "Add an errata to a changeset"
  param :changeset_id, :number
  param :erratum, Hash, :required => true do
    param :erratum_id, :number, :desc => "id of the errata to add"
    param :product_id, :number, :desc => "product which contains the errata"
  end
  def add_erratum
    product = find_product(params[:erratum][:product_id])
    erratum = Errata.find_by_errata_id(params[:erratum][:id])

    @changeset.add_erratum!(erratum, product)
    respond_for_create :resource => @changeset, :template => :show
  end

  api :DELETE, "/changesets/:changeset_id/errata/:erratum_id", "Remove an errata from a changeset"
  param :changeset_id, :number
  param :erratum_id, :number, :desc => "id of the erratum-changeset relation"
  def remove_erratum
    ChangesetErratum.find(params[:id]).destroy
    respond_for_show :resource => @changeset, :template => :show
  end

  api :POST, "/changesets/:changeset_id/repositories", "Add a repository to a changeset"
  param :changeset_id, :number
  param :repository, Hash, :required => true do
    param :id, :number, :desc => "id of the repository to add"
  end
  def add_repo
    repository = Repository.find(params[:repository][:id])
    @changeset.add_repository!(repository)
    respond_for_create :resource => @changeset, :template => :show
  end

  api :DELETE, "/changesets/:changeset_id/repositories/:repository_id", "Remove a repository from a changeset"
  param :changeset_id, :number
  param :repository_id, :number, :desc => "id of the repository to remove"
  def remove_repo
    repository = Repository.find(params[:id])
    @changeset.remove_repository!(repository)
    respond_for_show :resource => @changeset, :template => :show
  end

  api :POST, "/changesets/:changeset_id/content_views", "Add a content view to a changeset"
  param :changeset_id, :number, :desc => "id of the product to remove"
  param :content_view, Hash, :required => true do
    param :id, :number, :desc => "id of the content view to add"
  end
  def add_content_view
    @changeset.add_content_view! @view
    respond_for_create :resource => @changeset, :template => :show
  end

  api :DELETE, "/changesets/:changeset_id/content_views/:content_view_id", "Remove a content_view from a changeset"
  param :changeset_id, :number
  param :content_view_id, :number, :desc => "id of the content view to remove"
  def remove_content_view
    @changeset.remove_content_view!(@view)
    respond_for_show :resource => @changeset, :template => :show
  end

  api :POST, "/changesets/:changeset_id/distributions", "Add a distribution to a changeset"
  param :changeset_id, :number
  param :distribution, Hash, :required => true do
    param :distribution_id, :number, :desc => "id of the distribution to add"
    param :product_id, :number, :desc => "id of a product which contains the distribution"
  end
  def add_distribution
    product = find_product(params[:distribution][:product_id])
    @changeset.add_distribution!(params[:distribution][:distribution_id], product)
    respond_for_create :resource => @changeset, :template => :show
  end

  api :DELETE, "/changesets/:changeset_id/distributions/:distribution_id", "Remove a distribution from a changeset"
  param :changeset_id, :number
  param :distribution_id, :number, :desc => "id of the distribution to remove"
  def remove_distribution
    ChangesetErratum.find(params[:id]).destroy
    respond_for_show :resource => @changeset, :template => :show
  end

  private

  def find_changeset
    @changeset = Changeset.find_by_id(params[:changeset_id]) or
        raise HttpErrors::NotFound, _("Couldn't find changeset '%s'") % params[:changeset_id]
  end

  def find_content_view
    content_view_id = params.try(:[], :content_view).try(:[], :id) || params.try(:[], :id)
    @view           = ContentView.find_by_id(content_view_id)
    raise HttpErrors::NotFound, _("Couldn't find content view '%s'") % content_view_id if @view.nil?
  end

  def find_product(product_id)
    product = Product.find_by_cp_id(product_id.to_s)
    raise HttpErrors::NotFound, _("Couldn't find product with id '%s'") % product_id if product.nil?
    return product
  end

end
