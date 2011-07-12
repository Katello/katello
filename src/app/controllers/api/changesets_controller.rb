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

class Api::ChangesetsController < Api::ApiController

  before_filter :find_environment, :only => [:index, :create]
  before_filter :find_changeset, :only => [:show, :destroy, :update_content]
  respond_to :json

  def index
    render :json => @environment.working_changesets.where(params.slice(:name))
  end


  def show
    render :json => @changeset.to_json(:include => [:products, :packages, :errata, :repos])
  end


  def create
    @changeset = Changeset.new(params[:changeset])
    @changeset.environment = @environment
    @changeset.save!

    render :json => @changeset
  end


  def destroy
    @changeset.destroy
    render :text => _("Deleted changeset '#{params[:id]}'"), :status => 200
  end


  def update_content

    update_items params[:patch][:products] do |action, name|
      prod = find_product_by_name name
      @changeset.products << prod     if action == "+"
      @changeset.products.delete prod if action == "-"
    end

    update_items params[:patch][:packages] do |action, name|
      pack = create_changeset_package name
      @changeset.packages << pack if action == "+"
      ChangesetPackage.destroy_all(:package_id => pack.package_id, :changeset_id => @changeset.id) if action == "-"
    end

    update_items params[:patch][:errata] do |action, name|
      erratum = create_changeset_erratum name
      @changeset.errata << erratum if action == "+"
      ChangesetErratum.destroy_all(:errata_id => erratum.errata_id, :changeset_id => @changeset.id) if action == "-"
    end

    update_items params[:patch][:repos] do |action, name|
      repo = create_changeset_repo name
      @changeset.repos << repo if action == "+"
      ChangesetRepo.destroy_all(:repo_id => repo.repo_id, :changeset_id => @changeset.id) if action == "-"
    end

    @changeset.save!
    render :json => @changeset.to_json(:include => [:products, :packages, :errata, :repos])
  end


  def update_items items, &block
    return if items.nil?

    for item in items do
      action = item[0,1]
      name   = item[1,item.length]

      if (action != "+") && (action != "-")
        raise Errors::PatchSyntaxException.new("Patch syntax error.")
      end

      yield action, name
    end
  end


  def find_product_by_name product_name
    prod = @changeset.environment.products.find_by_name(product_name)
    raise Errors::ChangesetContentException.new("Product not found within this environment.") if prod.nil?
    prod
  end


  def create_changeset_package package_name
    @changeset.products.each do |product|
      product.repos(@changeset.environment).each do |repo|
        #search for package in all repos in a product
        idx = repo.packages.index do |p| p.name == package_name end
        if idx != nil
          pack = repo.packages[idx]
          return ChangesetPackage.new(:package_id => pack.id, :display_name => package_name, :product_id => product.id, :changeset => @changeset)
        end
      end
    end
    raise Errors::ChangesetContentException.new("Package not found within this environment.")
  end


  def create_changeset_erratum erratum_id
    @changeset.products.each do |product|
      product.repos(@changeset.environment).each do |repo|
        #search for erratum in all repos in a product
        idx = repo.errata.index do |e| e.id == erratum_id end
        if idx != nil
          erratum = repo.errata[idx]
          return ChangesetErratum.new(:errata_id => erratum.id, :display_name => erratum_id, :product_id => product.id, :changeset => @changeset)
        end
      end
    end
    raise Errors::ChangesetContentException.new("Erratum not found within this environment.")
  end


  def create_changeset_repo repo_name
    @changeset.products.each do |product|
      repos = product.repos(@changeset.environment)
      idx = repos.index do |r| r.name == repo_name end
      if idx != nil
        repo = repos[idx]
        return ChangesetRepo.new(:repo_id => repo.id, :display_name => repo_name, :product_id => product.id, :changeset => @changeset)
      end
    end
    raise Errors::ChangesetContentException.new("Repository not found within this environment.")
  end


  def find_changeset
    @changeset = Changeset.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find changeset '#{params[:id]}'") if @changeset.nil?
    @changeset
  end


  def find_environment
    @environment = KPEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    @environment
  end

end
