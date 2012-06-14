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

class ContentSearchController < ApplicationController


  def authorize
    {
        :index => lambda{true}
    }
  end

  def index
    render :index, :locals=>{:environments=>my_environments}
  end

  def my_environments
    paths = current_organization.promotion_paths
    library = {:id=>current_organization.library.id, :name=>current_organization.library.name, :select=>true}
    paths.collect do |path|
      [library] + path.collect{|e| {:id=>e.id, :name=>e.name, :select=>true} }
    end
  end

  def errata
   render :json=>[] 
  end

  def products

    ids = param_product_ids 
    if !ids.empty?
      products = current_organization.products.where(:id=>ids)
    else
      products = current_organization.products
    end
    products = products.collect do |p|
       p_list = {}

       p_list['id'] = p.id
       p_list['name'] = p.name
       p_list['cols'] = p.environment_ids
       p_list
    end
    render :json=>products
  end

  def repos
    
    repo_ids = process_repo_params
    product_ids = param_product_ids
   
    print repo_ids.inspect
     
    if repo_ids.is_a? Array
        repos = Repository.readable(current_organization.library).where(:id=>repo_ids)

    elsif repo_ids
      readable = Repository.readable(current_organization.library).collect{|r| r.id}
      repos = Repository.search do
        query {string repo_ids, {:default_field=>'name'}}
        filter "and", [
            {:terms => {:id => readable}},
            {:terms => {:enabled => [true]}}
        ]
      end
   
    elsif !product_ids.empty? 
        repos = []
        Product.readable(current_organization).where(:id=>product_ids).each do |p|
          repos = repos + Repository.readable_for_product(current_organization.library, p)
        end
    else 
        repos = Repository.readable(current_organization.library)
    end
    repos = repos.collect do |r| 
        {:id=>r.id, :name=>r.name, :cols=>[current_organization.library.id]}
    end
    render :json=>repos
  end


  private

  def param_product_ids 
    ids = params[:products][:autocomplete].collect{|p|p["id"]} if params[:products]
    ids || []
  end

  def process_repo_params
    ids = params[:repos][:autocomplete].collect{|p|p["id"]} if params[:repos] && params[:repos][:autocomplete]
    search = params[:repos][:search] if params[:repos] && params[:repos][:search]
    if search && !search.empty?
        return search
    elsif ids && !ids.empty?
        return ids
    else
        return nil
    end
  end

  



end
