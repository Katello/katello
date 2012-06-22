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
    render :json=>product_rows(products)
  end

  def repos
    
    repo_ids = process_params :repos
    product_ids = param_product_ids

    if repo_ids.is_a? Array #repos were auto_completed
        repos = Repository.readable(current_organization.library).where(:id=>repo_ids)

    elsif repo_ids #repos were searched
      readable = Repository.readable(current_organization.library).collect{|r| r.id}
      repos = repo_search(repo_ids, readable)
    elsif !product_ids.empty? #products were autocompleted
        repos = []
        Product.readable(current_organization).where(:id=>product_ids).each do |p|
          repos = repos + Repository.readable_for_product(current_organization.library, p)
        end
    else #get all
        repos = Repository.readable(current_organization.library)
    end

    products = repos.collect{|r| r.product}.uniq
    render :json=>(product_rows(products) + repo_rows(repos))
  end


  def packages
    repo_ids_in = process_params :repos
    product_ids_in = param_product_ids
    package_ids_in = process_params :packages

    repo_ids = nil


    if repo_ids_in.is_a? Array
      repo_ids = repo_ids_in
    elsif repo_ids_in
      readable = Repository.readable(current_organization.library).collect{|r| r.id}
      repo_ids = repo_search(repo_ids, readable).collect{|r| r.id}
    else
      if !product_ids_in.empty?
        products = Product.readable(current_organization).where(:id=>product_ids_in)
      else
        products = Product.readable(current_organization)
      end
      repo_ids = []
      products.each do |p|
        repo_ids = repo_ids + Repository.readable_for_product(current_organization.library, p).collect{|r| r.id}
      end
    end

    product_repo_map = {}

    Repository.where(:id=>repo_ids).each do |r|
      product_repo_map[r.product.id] ||= []
      product_repo_map[r.product.id] << r.id
    end

    rows = []
    product_repo_map.each{|p_id, repo_ids| rows = rows + (spanned_product_package_count(p_id, repo_ids, package_ids_in) || [])}
    render :json=>rows
  end

  private


  def repo_rows repos
    repos.collect do |repo|
        all_repos = repo.other_repos_with_same_product_and_content + [repo.pulp_id]
        cols = {}
        Repository.where(:pulp_id=>all_repos).each do |r|
          cols[r.environment.id] = {:hover => r.package_count}
        end
        {:id=>"repo_#{repo.id}", :parent_id=>"product_#{repo.product.id}", :name=>repo.name, :cols=>cols}
    end
  end

  def product_rows products
    products.collect do |p|
      cols = {}
      p.environments.collect do |env|
        cols[env.id] = {:display => p.total_package_count(env)}
      end
       {:id=>"product_#{p.id}", :name=>p.name, :cols=>cols}
    end
  end

  def param_product_ids 
    ids = params[:products][:autocomplete].collect{|p|p["id"]} if params[:products]
    ids || []
  end

  def process_params type
    ids = params[type][:autocomplete].collect{|p|p["id"]} if params[type] && params[type][:autocomplete]
    search = params[type][:search] if params[type] && params[type][:search]
    if search && !search.empty?
        return search
    elsif ids && !ids.empty?
        return ids
    else
        return nil
    end
  end

  def repo_search term, readable_list
    Repository.search :load=>true do
      query {string term, {:default_field=>'name'}}
      filter "and", [
          {:terms => {:id => readable_list}},
          {:terms => {:enabled => [true]}}
      ]
    end
  end


  def spanned_product_package_count product_id, repo_ids, pkg_search
    rows = []
    product = Product.find(product_id)
    product_envs = {}
    product_envs.default = 0

    repo_ids.each do |repo_id|
      repo = Repository.find(repo_id)
      repo_span = spanned_repo_package_count(repo, pkg_search)
      if repo_span
        rows << {:name=>repo.name, :cols=>repo_span, :id=>"repo_#{repo.id}", :parent_id=>"product_#{product_id}"}
        repo_span.values.each do |span|
          product_envs[span[:id]] += span[:display]
        end
      end
    end
    cols = {}
    product_envs.each{|env_id, count| cols[env_id] = {:id=>env_id, :display=>count}}
    if rows.empty?
      return nil
    else
      return [{:name=>product.name, :id=>"product_#{product_id}", :cols=>cols}] + rows
    end
  end

  #Given a repo and a pkg_search (id array or hash),
  #  return a array of {:id=>env_id, :display=>search.total}
  def spanned_repo_package_count repo, pkg_search

    spanning_repos = repo.other_repos_with_same_product_and_content + [repo.pulp_id]


    to_ret = {}
    repo_total = 0



    Repository.where(:pulp_id=>spanning_repos).each do |repo|
      a = Time.now
      search = Tire.search Glue::Pulp::Package.index do
        query do
          if pkg_search.is_a?(Array) || pkg_search.nil?
            all
          else
            string pkg_search, {:default_field=>'nvrea'}
          end
        end

        if  pkg_search.is_a? Array
          filter :terms, :id => package_ids_in
        end
        filter :terms, :repoids => [repo.pulp_id]
      end
      b = Time.now
      print (b - a)*1000
      print "\n"
      results = search.results
      repo_total += results.total
      to_ret[repo.environment_id] = {:id=>repo.environment_id, :display=>results.total}
    end
    repo_total == 0 ? nil : to_ret
  end
end
