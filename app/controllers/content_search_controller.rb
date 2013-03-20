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

  include ContentSearchHelper

  before_filter :find_repo, :only => [:repo_packages, :repo_errata]
  before_filter :find_repos, :only => [:repo_compare_packages, :repo_compare_errata]
  before_filter :setup_utils

  def rules
    contents_test = lambda{!KTEnvironment.content_readable(current_organization).empty?}
    {
        :index => contents_test,
        :errata => contents_test,
        :products => contents_test,
        :repos => contents_test,
        :my_environments => contents_test,
        :packages => contents_test,
        :packages_items => contents_test,
        :errata_items => contents_test,
        :view_packages => contents_test,
        :repo_packages => contents_test,
        :repo_errata => contents_test,
        :repo_compare_errata =>contents_test,
        :repo_compare_packages =>contents_test,
        :view_compare_errata =>contents_test,
        :view_compare_packages =>contents_test,
        :views => contents_test
    }
  end

  def section_id
    "content_search"
  end

  def index
    render :index, :locals=>{:environments=>environment_paths(library_path_element("contents_readable?"), environment_path_element("contents_readable?"))}
  end

  def products
    view_ids = param_view_ids
    view_search = ContentSearch::ContentViewSearch.new(:name => _("Content View"),
                                                       :view_ids => view_ids)

    product_search = ContentSearch::ProductSearch.new(:name => _('Products'),
                                                      :product_ids => param_product_ids,
                                                      :view_ids => view_ids
                                                     )
    render :json => {:rows=>(view_search.rows + product_search.rows), :name=>_("Products")}
  end

  def views
    ids = param_view_ids
    view_search = ContentSearch::ContentViewSearch.new(:name => _("Content View"),
                                                       :view_ids => ids
                                                      )
    render :json => view_search
  end

  def repos
    repo_ids      = process_params :repos
    product_ids   = param_product_ids
    view_ids      = param_view_ids

    repos = collect_repos(repo_ids, product_ids)

    envs = process_env_ids
    mode = process_search_mode

    unless mode == :all
      repos = repos.select do |repo|
        repo_envs = repo.environmental_instances.collect(&:environment)
        cmp = (envs - repo_envs ).empty?
        mode == :shared ? cmp : !cmp
      end
    end

    products = repos.collect(&:product).uniq
    product_search = ContentSearch::ProductSearch.new(:product_ids => products.map(&:id),
                                                      :view_ids=>view_ids)


    view_search = ContentSearch::ContentViewSearch.new(:name => _("Content View"),
                                                       :view_ids => view_ids)
    rows = view_search.rows
    rows.concat(product_search.rows)
    view_search.views.each do |view|
      tmp_rows = repo_rows(view, repos)
      rows.concat(tmp_rows)
    end

    render :json=>{:rows=>rows, :name=>_('Repositories')}
  end

  def packages
    repo_ids      = process_params :repos
    product_ids   = param_product_ids
    package_ids   = process_params :packages

    repos = collect_repos(repo_ids, product_ids)
    product_repo_map = map_repos_to_product(repos)

    rows = []
    product_repo_map.each do |p_id, product_repo_ids|
      rows.concat spanned_product_content(p_id, product_repo_ids, 'package', package_ids)
    end

    render :json => {:rows => rows, :name => _('Packages')}
  end

  def errata
    repo_ids      = process_params :repos
    product_ids   = param_product_ids
    errata_ids    = process_params :errata

    repos = collect_repos(repo_ids, product_ids)
    product_repo_map = map_repos_to_product(repos)

    rows = []
    product_repo_map.each do |p_id, product_repo_ids|
      rows.concat spanned_product_content(p_id, product_repo_ids, 'errata', errata_ids)
    end
    render :json => {:rows => rows, :name => _('Errata')}
  end

  #similar to :packages, but only returns package rows with an offset for a specific repo
  def packages_items
    repo = Repository.libraries_content_readable(current_organization).where(:id=>params[:repo_id]).first
    offset = params[:offset].try(:to_i) || 0
    pkgs = spanned_repo_content(repo, 'package', process_params(:packages), params[:offset], process_search_mode, process_env_ids) || {:content_rows=>[]}
    meta = metadata_row(pkgs[:total], offset + pkgs[:content_rows].length,
                        {:repo_id=>repo.id}, repo.id, "repo_#{repo.id}")
    render :json=>{:rows=>(pkgs[:content_rows] + [meta])}
  end

  # similar to :package_items but only returns package rows for content view grids
  def view_packages
    repo = Repository.libraries_content_readable(current_organization).where(:id=>params[:repo_id]).first
    offset = params[:offset].try(:to_i) || 0

    cv_env_ids = repo.clones.map do |r|
      {:view_id => r.content_view.id, :env_id => r.environment}
    end
    options = {:is_package => true,
               :cv_env_ids => cv_env_ids}
    comparison = ContentSearch::ContentViewComparison.new(options)
    render :json => {:rows => comparison.package_rows + comparison.metadata_rows}
  end

  #similar to :errata, but only returns errata rows with an offset for a specific repo
  def errata_items
    repo = Repository.libraries_content_readable(current_organization).where(:id=>params[:repo_id]).first
    errata = spanned_repo_content(repo, 'errata', process_params(:errata), params[:offset], process_search_mode, process_env_ids) || {:content_rows=>[]}
    meta = metadata_row(errata[:total], params[:offset] + errata[:content_rows].length,
                        {:repo_id=>repo.id}, repo.id, "repo_#{repo.id}")
    render :json=>{:rows=>(errata[:content_rows] + [meta])}
  end


  def repo_packages
    offset = params[:offset] || 0
    packages = Package.search('', offset, current_user.page_size, [@repo.pulp_id])
    rows = packages.collect do |pack|
      {:name => display = package_display(pack),
        :id => pack.id, :cols => {:description => {:display => pack.description}}, :data_type => "package", :value => pack.nvrea}
    end

    if packages.total > current_user.page_size
      rows += [metadata_row(packages.total, offset.to_i + rows.length, {:repo_id=>@repo.id}, @repo.id)]
    end
    render :json => { :rows => rows, :name => @repo.name }
  end

  def repo_errata
    offset = params[:offset] || 0
    errata = Errata.search('', offset, current_user.page_size, :repoids => [@repo.pulp_id])
    rows = errata.collect do |e|
      {:name => errata_display(e), :id => e.id, :data_type => "errata", :value => e.id,
          :cols => {:title => {:display => e[:title]},
                    :type => {:display => e[:type]},
                    :severity => {:display => e[:severity]}
          }
      }
    end
    if errata.total > current_user.page_size
      rows += [metadata_row(errata.total, offset.to_i + rows.length, {:repo_id=>@repo.id}, @repo.id)]
    end
    render :json => { :rows => rows, :name => @repo.name }
  end

  def repo_compare_packages
    repo_compare_content true, params[:offset] || 0
  end


  def repo_compare_errata
    repo_compare_content false, params[:offset] || 0
  end

  def view_compare_packages
    options = {:is_package => true,
               :cv_env_ids => params[:views].values}
    render :json => ContentSearch::ContentViewComparison.new(options)
  end

  def view_compare_errata
    options = {:is_package => false,
               :cv_env_ids => params[:views].values}
    render :json => ContentSearch::ContentViewComparison.new(options)
  end

  private

  def repo_compare_content is_package, offset
    repo_map = {}
    @repos.each do |r|
      repo_map[r.pulp_id] = r
    end
    if is_package
      packages = Package.search('', params[:offset], current_user.page_size, repo_map.keys, [:nvrea_sort, "ASC"], process_search_mode())
    else
      packages = Errata.search('', params[:offset], current_user.page_size, :repoids =>  repo_map.keys, :search_mode => process_search_mode)
    end
    rows = packages.collect do |pack|
      cols = {}
      (pack.repoids & repo_map.keys).each do |r|
        cols[repo_map[r].id] = {}
      end

      if is_package
        name = package_display(pack)
      else
        name = errata_display(pack)
      end
      {:name => name, :id => pack.id, :cols => cols}
    end

    cols = {}
    sort_repos(@repos).each{|r| cols[r.id] = {:id=>r.id, :content => repo_compare_name_display(r)}}
    if !packages.empty?
      rows += [metadata_row(packages.total, offset.to_i + rows.length, {:repos=>params[:repos]}, 'compare')] if packages.total > current_user.page_size
    end
    render :json => {:rows=>rows, :cols=>cols, :name=>_("Repository Comparison")}
  end

  #take in a set of repos and sort based on environment
  def sort_repos repos
    env_to_repo = {}
    repos.each do |r|
      env_to_repo[r.environment.id] ||= []
      env_to_repo[r.environment.id] << r
    end
    envs = [current_organization.library] + current_organization.promotion_paths.flatten
    to_ret = []
    envs.each{|e|  to_ret += (env_to_repo[e.id] || [])}
    to_ret
  end


  def find_repos
    @repos = []
    params[:repos].values.each do |item|
      library_instance = Repository.readable_in_org(current_organization).find(item[:repo_id])
      @repos += library_instance.environmental_instances.select{|r| r.environment_id.to_s == item[:env_id]}
    end
  end

  def find_repo
    @repo = Repository.readable_in_org(current_organization).find(params[:repo_id])
  end

  def repo_rows view, repos
    env_ids = KTEnvironment.content_readable(current_organization).pluck(:id)
    repos.collect do |repo|
        repo = Repository.in_content_views([view]).where(:library_instance_id=>repo.id).first
        all_repos = repo.environmental_instances(true).pluck(:pulp_id)
        cols = {}
        Repository.where(:pulp_id=>all_repos).each do |r|
          cols[r.environment.id] = {:hover => repo_hover_html(r)} if env_ids.include?(r.environment_id)
        end
        {:id=>"repo_#{repo.id}", :comparable=>true, :parent_id=>"view_#{view.id}_product_#{repo.product.id}",
        :name=>repo.name, :cols=>cols, :data_type => "repo", :value => repo.name}
    end
  end

  def repo_hover_html repo
    render_to_string :partial=>'repo_hover', :locals=>{:repo=>repo}
  end

  def param_product_ids
    ids = params[:products][:autocomplete].collect{|p|p["id"]} if params[:products]
    ids || []
  end

  def param_view_ids
    ids = params[:views][:autocomplete].collect{|p|p["id"]} if params[:views]
    ids || []
  end

  def process_search_mode
    case params[:mode]
      when "shared"
        :shared
      when "unique"
        :unique
      else
        :all
    end
  end

  def process_env_ids
    mode = process_search_mode
    unless mode == :all
      env_ids = params[:environments]
      KTEnvironment.content_readable(current_organization).where(:id => env_ids)
    end
  end

  # given a search object as params, return the search for a particular type
  #  this could either be a search string, or array of ids

  def process_params(type)
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

  def repo_search(term, readable_list, product_ids = nil)
    conditions = [{:terms => {:id => readable_list}},
                  {:terms => {:enabled => [true]}}]
    conditions << {:terms => {:product_id => product_ids}} unless product_ids.blank?

    #get total repos
    found = Repository.search(:load => true) do
      query {string term, {:default_field => 'name'}} unless term.blank?
      filter "and", conditions
      size 1
    end
    Repository.search(:load => true) do
      query {string term, {:default_field => 'name'}} unless term.blank?
      filter "and", conditions
      size found.total
    end
  end

  def collect_repos(repo_ids, product_ids)
    # is this neccessary?
    unless product_ids.blank?
      product_ids = Product.readable(current_organization).where(:id => product_ids).pluck(:id)
    end

    # repos were searched by string
    unless repo_ids.is_a? Array
      search_string = repo_ids
      repo_ids      = Repository.enabled.libraries_content_readable(current_organization).pluck(:id)
    end

    repo_search(search_string, repo_ids, product_ids)
  end

  # Given a repos, and a repo_search, return a
  # product_id => [repo_ids] hash
  def map_repos_to_product(repos)
    repos.inject({}) do |map, repo|
      map[repo.product.id] ||= []
      map[repo.product.id] << repo.id
      map
    end
  end

  def metadata_row(total_count, current_count, data, unique_id, parent_id=nil)
    to_ret = {:total=>total_count,  :current_count=>current_count, :page_size=>current_user.page_size,
       :data=>data, :id=>"repo_metadata_#{unique_id}",
       :metadata=>true
    }

    to_ret[:parent_id] = parent_id if parent_id
    to_ret
  end

  def spanned_product_content(product_id, repo_ids, content_type, search_obj, search_mode = nil, environments = nil)
    rows = []
    product = Product.find(product_id)
    content_rows = []
    product_envs = {}
    product_envs.default = 0
    accessible_env_ids = KTEnvironment.content_readable(current_organization).pluck(:id)
    search_mode ||= process_search_mode
    environments ||= process_env_ids

    repo_ids.each do |repo_id|
      repo = Repository.find(repo_id)
      repo_span = spanned_repo_content(repo, content_type,  search_obj, 0, search_mode, environments)
      if repo_span
        rows << {:name=>repo.name, :cols=>repo_span[:repo_cols], :id=>"repo_#{repo.id}",
                 :parent_id=>"product_#{product_id}", :data_type => "repo", :value => repo.name}
        repo_span[:repo_cols].values.each do |span|
          product_envs[span[:id]] += span[:display]
        end
        content_rows += repo_span[:content_rows]
        if repo_span[:total] > current_user.page_size
          content_rows <<  metadata_row(repo_span[:total], current_user.page_size,
                                        {:repo_id=>repo.id}, repo.id, "repo_#{repo.id}")
        end
      end
    end
    cols = {}
    product_envs.each{|env_id, count| cols[env_id] = {:id=>env_id, :display=>count} if accessible_env_ids.include?(env_id)}
    if rows.empty?
      []
    else
      [{:name=>product.name, :id=>"product_#{product_id}", :cols=>cols, :data_type => "product", :value => product.name }] + rows + content_rows
    end
  end

  #Given a repo and a pkg_search (id array or hash),
  #  return a array of {:id=>env_id, :display=>search.total}
  #
  #
  def spanned_repo_content library_repo, content_type, content_search_obj, offset=0, search_mode = :all, environments = []
    spanning_repos = library_repo.environmental_instances
    accessible_env_ids = KTEnvironment.content_readable(current_organization).pluck(:id)

    unless environments.nil? || environments.empty?
      spanning_repos.delete_if do |repo|
        !(environments.include? repo.environment)
      end
      if search_mode != :all && spanning_repos.length < environments.length
        # if the number of environments is greater than the repos to compare
        # it implies that one of the envs does not have this repo
        # which means that there is nothing shared between em
        # and all rows are "not shared" or "unique"
        return nil if search_mode == :shared
        search_mode = :all
      end
    end
    to_ret = {}
    content_attribute = content_type.to_sym == :package ? 'nvrea' : 'errata_id'
    content_class = content_type.to_sym == :package ? Package : Errata
    content = multi_repo_content_search(content_class, content_search_obj, spanning_repos, offset, content_attribute, search_mode)

    return nil if content.total == 0

    spanning_repos.each do |repo|
      results = multi_repo_content_search(content_class, content_search_obj, spanning_repos, offset, content_attribute, search_mode,repo)
      to_ret[repo.environment_id] = {:id=>repo.environment_id, :display=>results.total} if accessible_env_ids.include?(repo.environment_id)
    end

    {:content_rows=>spanning_content_rows(content, content_type, library_repo, spanning_repos),
     :repo_cols=>to_ret, :total=>content.total}
  end


  # perform a content search (errata or package)
  #
  # content_class   either Glue::Pulp::Package or Glue::Pulp::Errata
  # search_obj      either a search string or array of ids
  # repo            repo to search in
  # offset          offset of the search
  # default_field   default field to search if none specifiec
  def  multi_repo_content_search( content_class, search_obj, repos, offset, default_field, search_mode = :all, in_repo = nil)
    user = current_user
    search = Tire::Search::Search.new(content_class.index)
    search.instance_eval do
      query do
        if search_obj.is_a?(Array) || search_obj.nil?
          all
        else
          string search_obj, {:default_field=>default_field}
        end
      end
      sort { by "#{default_field}_sort", 'asc'}
      fields [:id, :name, :nvrea, :repoids, :type, :errata_id]
      size user.page_size
      from offset
      if  search_obj.is_a? Array
        filter :terms, :id => search_obj
      end
      if in_repo
        filter :terms, :repoids => [in_repo.pulp_id]
      end
    end
    repoids = repos.collect{|r| r.pulp_id}
    Util::Package.setup_shared_unique_filter(repoids, search_mode, search)
    search.perform.results
  rescue Tire::Search::SearchRequestFailed => e
    Util::Support.array_with_total
  end


  # creates rows out of a list of content (Errata or package) for a particular
  #     library repo and its spanning clones across environments
  #
  # content_list   list of package or errata items
  # id_prefix      prefix for the rows (either 'package' or 'errata')
  # parent_repo    the library repo instance (or the parent row)
  # spanned_repos  all other instances of repos across all environments
  def spanning_content_rows(content_list, id_prefix, parent_repo, spanned_repos)
    env_ids = KTEnvironment.content_readable(current_organization).pluck(:id)
    to_ret = []
    content_list.each do |item|
      if id_prefix == 'package'
        display = package_display(item)
        value = item.nvrea
      else
        display = errata_display(item)
        value = item.id
      end
      row = {:id=>"repo_#{parent_repo.id}_#{id_prefix}_#{item.id}", :parent_id=>"repo_#{parent_repo.id}", :cols=>{},
             :name=>display, :data_type => id_prefix, :value => value}
      spanned_repos.each do |repo|
        if item.repoids.include? repo.pulp_id
            row[:cols][repo.environment_id] = {:id=>repo.environment_id} if env_ids.include?(repo.environment_id)
        end
      end
      to_ret << row
    end
    to_ret
  end

  def setup_utils
    ContentSearch::SearchUtils.current_organization = current_organization
    ContentSearch::SearchUtils.current_user = current_user
    ContentSearch::SearchUtils.mode = params[:mode]
    ContentSearch::SearchUtils.env_ids = params[:environments]
    ContentSearch::SearchUtils.offset = params[:offset] || 0
  end

end
