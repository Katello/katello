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
  before_filter :find_repo, :only => [:repo_packages, :repo_errata]
  before_filter :find_repos, :only => [:repo_compare_packages, :repo_compare_errata]

  def rules
    contents_test = lambda{true}
    {
        :index => lambda{true},
        :errata => contents_test,
        :products => contents_test,
        :repos => contents_test,
        :my_environments => contents_test,
        :packages => contents_test,
        :packages_items => contents_test,
        :errata_items => contents_test,
        :repo_packages => contents_test,
        :repo_errata => contents_test,
        :repo_compare_errata =>contents_test,
        :repo_compare_packages =>contents_test
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
      products = current_organization.products.engineering.where(:id=>ids)
    else
      products = current_organization.products.engineering
    end
    render :json=>product_rows(products)
  end

  def repos
    repo_ids = process_params :repos
    product_ids = param_product_ids

    if repo_ids.is_a? Array #repos were auto_completed
        repos = Repository.enabled.readable(current_organization.library).where(:id=>repo_ids)
    elsif repo_ids #repos were searched
      readable = Repository.enabled.readable(current_organization.library).collect{|r| r.id}
      repos = repo_search(repo_ids, readable)
    elsif !product_ids.empty? #products were autocompleted
        repos = []
        Product.readable(current_organization).where(:id=>product_ids).each do |p|
          repos = repos + Repository.enabled.readable_for_product(current_organization.library, p)
        end
    else #get all
        repos = Repository.enabled.readable(current_organization.library)
    end

    products = repos.collect{|r| r.product}.uniq
    render :json=>(product_rows(products) + repo_rows(repos))
  end

  def packages
    repo_ids_in = process_params :repos
    product_ids_in = param_product_ids
    package_ids_in = process_params :packages

    product_repo_map = extract_repo_ids(product_ids_in, repo_ids_in)
    rows = []
    product_repo_map.each{|p_id, repo_ids| rows = rows + (spanned_product_content(p_id, repo_ids, 'package', package_ids_in) || [])}
    render :json=>rows
  end

  def errata
    repo_ids_in = process_params :repos
    product_ids_in = param_product_ids
    package_ids_in = process_params :errata

    product_repo_map = extract_repo_ids(product_ids_in, repo_ids_in)
    rows = []
    product_repo_map.each{|p_id, repo_ids| rows = rows + (spanned_product_content(p_id, repo_ids, 'errata', package_ids_in) || [])}
    render :json=>rows
  end

  #similar to :packages, but only returns package rows with an offset for a specific repo
  def packages_items
    repo = Repository.where(:id=>params[:repo_id]).first
    pkgs = spanned_repo_content(repo, 'package', process_params(:packages), params[:offset]) || {:content_rows=>[]}
    render :json=>(pkgs[:content_rows] + [metadata_row(pkgs[:total], params[:offset] + pkgs[:content_rows].length, repo)])
  end

  #similar to :errata, but only returns errata rows with an offset for a specific repo
  def errata_items
    repo = Repository.where(:id=>params[:repo_id]).first
    errata = spanned_repo_content(repo, 'errata', process_params(:errata), params[:offset]) || {:content_rows=>[]}
    render :json=>(errata[:content_rows] + [metadata_row(errata[:total], params[:offset] + errata[:content_rows].length, repo)])
  end


  def repo_packages
    packages = Glue::Pulp::Package.search('', params[:offset], current_user.page_size, [@repo.pulp_id])
    rows = packages.collect do |pack|
      {:name => pack.nvrea, :id => pack.id, :cols => {:description => {:display => pack.description}}}
    end
    render :json => rows
  end

  def repo_errata
    errata = Glue::Pulp::Errata.search('', params[:offset], current_user.page_size, :repoids => [@repo.pulp_id])
    rows = errata.collect do |e|
      {:name => e.id, :id => e.id, :cols => {:title => {:display => e[:title]},
                                             :type => {:display => e[:type]},
                                              :issued => {:display => e[:issued]}
                                            }
      }
    end
    render :json => rows
  end


  def repo_compare_packages
    repo_compare_content true
  end


  def repo_compare_errata
    repo_compare_content false
  end


  private

  def repo_compare_content is_package
    repo_map = {}
    @repos.each do |r|
      repo_map[r.pulp_id] = r
    end
    if is_package
      packages = Glue::Pulp::Package.search('', params[:offset], current_user.page_size, repo_map.keys)
    else
      packages = Glue::Pulp::Errata.search('', params[:offset], current_user.page_size, :repoids =>  repo_map.keys)
    end
    rows = packages.collect do |pack|
      cols = {}
      (pack.repoids & repo_map.keys).each do |r|
        cols[repo_map[r].id] = {}
      end
      name = pack.id
      if is_package
        name = pack.nvrea
      end
      {:name => name, :id => pack.id, :cols => cols}
    end
    render :json => rows
  end

  def find_repos
    @repos = Repository.readable_in_org(current_organization).where(:id => params[:repos])
  end

  def find_repo
    @repo = Repository.readable_in_org(current_organization).find(params[:repo_id])
  end

  def repo_rows repos
    repos.collect do |repo|
        all_repos = repo.environmental_instances.collect{|r| r.pulp_id}
        cols = {}
        Repository.where(:pulp_id=>all_repos).each do |r|
          cols[r.environment.id] = {:hover => repo_hover_html(r)}
        end
        {:id=>"repo_#{repo.id}", :parent_id=>"product_#{repo.product.id}", :name=>repo.name, :cols=>cols}
    end
  end

  def repo_hover_html repo
    render_to_string :partial=>'repo_hover', :locals=>{:repo=>repo}
  end

  def product_rows products
    products.collect do |p|
      cols = {}
      p.environments.collect do |env|
        cols[env.id] = {:hover => product_hover_html(p, env)}
      end
       {:id=>"product_#{p.id}", :name=>p.name, :cols=>cols}
    end
  end

  def product_hover_html product, environment
    render_to_string :partial=>'product_hover', :locals=>{:product=>product, :env=>environment}
  end

  def param_product_ids 
    ids = params[:products][:autocomplete].collect{|p|p["id"]} if params[:products]
    ids || []
  end

  # given a search object as params, return the search for a particular type
  #  this could either be a search string, or array of ids
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


  #Given a product_search, and a repo_search, return a
  # product_id =>  [repo_ids]   hash
  def extract_repo_ids product_ids, repo_search
    repo_ids = []

    if repo_search.is_a? Array
      repo_ids = repo_search
    elsif repo_search
      readable = Repository.readable(current_organization.library).collect{|r| r.id}
      repo_ids = repo_search(repo_search, readable).collect{|r| r.id}
    else
      if !product_ids.empty?
        products = Product.readable(current_organization).where(:id=>product_ids)
      else
        products = Product.readable(current_organization)
      end
      products.each do |p|
        repo_ids = repo_ids + Repository.enabled.readable_for_product(current_organization.library, p).collect{|r| r.id}
      end
    end

    product_repo_map = {}

    Repository.where(:id=>repo_ids).each do |r|
      product_repo_map[r.product.id] ||= []
      product_repo_map[r.product.id] << r.id
    end
    product_repo_map
  end

  def metadata_row(total_count, current_count, repo)
    {:total=>total_count,  :current_count=>current_count, :page_size=>current_user.page_size,
       :parent_id=>"repo_#{repo.id}", :data=>{:repo_id=>repo.id}, :id=>"repo_metadata_#{repo.id}",
       :metadata=>true
    }
  end

  def spanned_product_content product_id, repo_ids, content_type, search_obj
    rows = []
    product = Product.find(product_id)
    content_rows = []
    product_envs = {}
    product_envs.default = 0

    repo_ids.each do |repo_id|
      repo = Repository.find(repo_id)
      repo_span = spanned_repo_content(repo, content_type,  search_obj)
      if repo_span
        rows << {:name=>repo.name, :cols=>repo_span[:repo_cols], :id=>"repo_#{repo.id}", 
                 :parent_id=>"product_#{product_id}"}
        repo_span[:repo_cols].values.each do |span|
          product_envs[span[:id]] += span[:display]
        end
        content_rows += repo_span[:content_rows]
        if repo_span[:total] > current_user.page_size
          content_rows <<  metadata_row(repo_span[:total], current_user.page_size, repo)
        end
      end
    end
    cols = {}
    product_envs.each{|env_id, count| cols[env_id] = {:id=>env_id, :display=>count}}
    if rows.empty?
      return nil
    else
      return [{:name=>product.name, :id=>"product_#{product_id}", :cols=>cols}] + rows + content_rows
    end
  end

  #Given a repo and a pkg_search (id array or hash),
  #  return a array of {:id=>env_id, :display=>search.total}
  #
  #
  def spanned_repo_content library_repo, content_type, content_search_obj, offset=0
    #library must be first, so subtract it from instance ids
    spanning_repos = [library_repo] + (library_repo.environmental_instances - [library_repo])
    to_ret = {}
    library_content = []
    library_total = 0
    content_attribute = content_type.to_sym == :package ? 'nvrea' : 'id'
    spanning_repos.each do |repo|
      content_class = content_type.to_sym == :package ? Glue::Pulp::Package : Glue::Pulp::Errata

      results = repo_content_search(content_class, content_search_obj, repo, offset, content_attribute).results
      if repo.environment.library?
        library_content = results
        library_total = results.total
        return nil if library_total == 0
      end
      to_ret[repo.environment_id] = {:id=>repo.environment_id, :display=>results.total}
    end

    {:content_rows=>spanning_content_rows(library_content, content_type, content_attribute, library_repo, spanning_repos),
     :repo_cols=>to_ret, :total=>library_total}
  end

  # perform a content search (errata or package)
  #
  # content_class   either Glue::Pulp::Package or Glue::Pulp::Errata
  # search_obj      eitehr a search string or array of ids
  # repo            repo to search in
  # offset          offset of the search
  # default_field   default field to search if none specifiec
  def repo_content_search( content_class, search_obj, repo, offset, default_field)
    user = current_user
    search = Tire.search content_class.index do
      query do
        if search_obj.is_a?(Array) || search_obj.nil?
          all
        else
          string search_obj, {:default_field=>default_field}
        end
      end

      fields [:id, :name, :nvrea, :repoids]
      sort { by "#{default_field}_sort", 'asc'}
      size user.page_size
      from offset


      if  search_obj.is_a? Array
        filter :terms, :id => search_obj
      end
      filter :terms, :repoids => [repo.pulp_id]
    end
  end

  # creates rows out of a list of content (Errata or package) for a particular
  #     library repo and its spanning clones across environments
  #
  # content_list   list of package or errata items
  # id_prefix      prefix for the rows (either 'package' or 'errata')
  # name_attribute  what to display as the name of each item in the row.  Will be called on each object
  # parent_repo    the library repo instance (or the parent row)
  # spanned_repos  all other instances of repos across all environments
  def spanning_content_rows(content_list, id_prefix, name_attribute, parent_repo, spanned_repos)
    to_ret = [] 
    for item in content_list:
        row = {:id=>"#{id_prefix}_#{item.id}", :parent_id=>"repo_#{parent_repo.id}", :cols=>{},
               :name=>item.send(name_attribute)}
        spanned_repos.each do |repo|
          if item.repoids.include? repo.pulp_id
              row[:cols][repo.environment_id] = {:id=>repo.environment_id}
          end
        end 
        to_ret << row
     end
     to_ret
  end 
end
