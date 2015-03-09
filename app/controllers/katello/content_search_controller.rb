#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  class ContentSearchController < Katello::ApplicationController
    include ContentSearchHelper

    before_filter :find_repo, :only => [:repo_packages, :repo_puppet_modules]
    before_filter :find_repos, :only => [:repo_compare_packages, :repo_compare_puppet_modules]
    before_filter :setup_utils

    def section_id
      "content_search"
    end

    def title
      _('Content Search')
    end

    def index
      render :index, :locals => { :environments => environment_paths(library_path_element("readable?"),
                                                                     environment_path_element("readable?")) }
    end

    def products
      views = process_views(process_params(:views))
      products = process_products(process_params(:products))
      view_search = ContentSearch::ContentViewSearch.new(:name => _("Content View"),
                                                         :views => views,
                                                         :organization => current_organization)

      product_search = ContentSearch::ProductSearch.new(:name => _('Products'),
                                                        :products => products,
                                                        :views => views,
                                                        :mode => @mode,
                                                        :organization => current_organization
                                                       )
      render :json => { :rows => (view_search.rows + product_search.rows), :name => _("Products") }
    end

    def views
      views = process_views(process_params :views)
      view_search = ContentSearch::ContentViewSearch.new(:name => _("Content View"),
                                                         :views => views,
                                                         :organization => current_organization,
                                                         :mode => @mode,
                                                         :comparable => true)
      render :json => view_search
    end

    def repos
      repo_ids = process_params(:repos)
      product_ids = process_params(:products)
      views = process_views(process_params(:views))
      repos = process_repos(repo_ids, product_ids)

      products = repos.collect(&:product).uniq
      product_search = ContentSearch::ProductSearch.new(:products => products,
                                                        :views => views,
                                                        :organization => current_organization)
      view_search = ContentSearch::ContentViewSearch.new(:name => _("Content View"),
                                                         :views => views,
                                                         :organization => current_organization)
      rows = view_search.rows + product_search.rows

      view_search.views.each do |view|
        repo_search = ContentSearch::RepoSearch.new(:name => _('Repositories'), :view => view, :repos => repos,
                                                    :comparable => true, :mode => @mode)
        rows.concat(repo_search.rows)
      end

      render :json => { :rows => rows, :name => _('Repositories') }
    end

    def packages
      repo_ids = process_params(:repos)
      product_ids = process_params(:products)
      views = process_views(process_params(:views))
      repos = process_repos(repo_ids, product_ids)
      package_ids = process_params(:packages)

      #construct a structure   view => { product => [repos] } for each view
      view_product_repo_map = view_product_repo_map(views, repos)

      view_hash = ContentSearch::ContentViewSearch.new(:name => _("Content View"),
                                                       :views => views,
                                                       :organization => current_organization)
      view_hash = view_hash.row_object_hash

      rows = []
      view_product_repo_map.each do |view, product_repo_map|
        prod_rows = product_repo_map.collect do |product, reps|
          spanned_product_content(view, product, reps, 'package', package_ids)
        end
        prod_rows.flatten!

        unless prod_rows.empty?
          rows << view_hash[view.id]
          rows.concat(prod_rows)
        end
      end
      render :json => { :rows => rows, :name => _('Packages') }
    end

    def view_product_repo_map(views, _library_repos)
      to_ret = {}
      views.each do |view|
        to_ret[view] = {}
        view.all_version_library_instances.each do |repo|
          to_ret[view][repo.product] ||= []
          to_ret[view][repo.product] << repo
        end
      end
      to_ret
    end

    def puppet_modules
      repo_ids = process_params(:repos)
      product_ids = process_params(:products)
      views = process_views(process_params(:views))
      repos = process_repos(repo_ids, product_ids)
      puppet_module_ids = process_params(:puppet_modules)

      #construct a structure   view => { product => [repos] } for each view
      view_product_repo_map = view_product_repo_map(views, repos)

      view_hash = ContentSearch::ContentViewSearch.new(:name => _("Content View"),
                                                       :views => views,
                                                       :organization => current_organization)
      view_hash = view_hash.row_object_hash

      rows = []
      view_product_repo_map.each do |view, product_repo_map|
        prod_rows = []
        product_repo_map.each do |product, reps|
          prod_rows.concat(spanned_product_content(view, product, reps, 'puppet_module', puppet_module_ids))
        end

        unless prod_rows.empty?
          rows << view_hash[view.id]
          rows.concat(prod_rows)
        end
      end

      render :json => { :rows => rows, :name => _('Puppet Modules') }
    end

    #similar to :packages, but only returns package rows with an offset for a specific repo
    def packages_items
      repo = Repository.libraries_content_readable(current_organization).where(:id => params[:repo_id]).first
      view = ContentView.readable.where(:id => params[:view_id]).first
      offset = params[:offset].try(:to_i) || 0

      pkgs = spanned_repo_content(view, repo, 'package', process_params(:packages),
                                  params[:offset], process_search_mode, process_env_ids)
      pkgs = { :content_rows => [] } unless pkgs

      meta = metadata_row(pkgs[:total], offset + pkgs[:content_rows].length,
                          { :repo_id => repo.id, :view_id => view.id },
                          "#{view.id}_#{repo.id}", ContentSearch::RepoSearch.id(view, repo))

      render :json => { :rows => (pkgs[:content_rows] + [meta]) }
    end

    # similar to :package_items but only returns package rows for content view grids
    def view_packages
      repo = Repository.libraries_content_readable(current_organization).where(:id => params[:repo_id]).first

      cv_env_ids = repo.clones.map do |r|
        { :view_id => r.content_view.id, :env_id => r.environment }
      end

      options = { :unit_type => :package,
                  :cv_env_ids => cv_env_ids,
                  :offset => params[:offset].try(:to_i) || 0 }

      comparison = ContentSearch::ContentViewComparison.new(options)

      render :json => { :rows => comparison.unit_rows + comparison.metadata_rows }
    end

    # similar to :puppet_module_items but only returns puppet module rows for content view grids
    def view_puppet_modules
      repo = Repository.libraries_content_readable(current_organization).where(:id => params[:repo_id]).first

      cv_env_ids = repo.clones.map do |r|
        { :view_id => r.content_view.id, :env_id => r.environment }
      end

      options = { :unit_type => :puppet_module,
                  :cv_env_ids => cv_env_ids,
                  :offset => params[:offset].try(:to_i) || 0 }

      comparison = ContentSearch::ContentViewComparison.new(options)

      render :json => { :rows => comparison.unit_rows + comparison.metadata_rows }
    end

    #similar to :puppet_modules, but only returns puppet modules rows with an offset for a specific repo
    def puppet_modules_items
      view = ContentView.readable.where(:id => params[:view_id]).first
      repo = Repository.libraries_content_readable(current_organization).where(:id => params[:repo_id]).first
      offset = params[:offset].try(:to_i) || 0

      puppet_modules = spanned_repo_content(view, repo, 'puppet_module',
                                            process_params(:puppet_modules),
                                            params[:offset], process_search_mode, process_env_ids)

      puppet_modules = { :content_rows => [] } unless puppet_modules

      meta = metadata_row(puppet_modules[:total], offset + puppet_modules[:content_rows].length,
                          { :repo_id => repo.id, :view_id => view.id },
                          "#{view.id}_#{repo.id}", ContentSearch::RepoSearch.id(view, repo))

      render :json => { :rows => (puppet_modules[:content_rows] + [meta]) }
    end

    def repo_packages
      offset = params[:offset] || 0
      packages = Package.legacy_search('', offset, current_user.page_size, [@repo.pulp_id])

      rows = packages.collect do |pack|
        { :name => package_display(pack),
          :id => pack.id, :cols => { :description => { :display => pack.description } },
          :data_type => "package", :value => pack.nvrea }
      end

      if packages.total > current_user.page_size
        rows += [metadata_row(packages.total, offset.to_i + rows.length, { :repo_id => @repo.id }, @repo.id)]
      end

      render :json => { :rows => rows, :name => @repo.name }
    end

    def repo_puppet_modules
      offset = params[:offset] || 0
      puppet_modules = PuppetModule.legacy_search('',  :start => offset, :page_size => current_user.page_size,
                                                       :repoids => [@repo.pulp_id])

      rows = puppet_modules.collect do |puppet_module|
        ContentSearch::Row.new(:id         => puppet_module.id,
                               :name       => puppet_module_display(puppet_module),
                               :cols       => { :description => { :display => puppet_module.description } },
                               :data_type  => "puppet_module",
                               :value      => puppet_module.name,
                               :comparable => puppet_module.comparable,
                               :object_id  => puppet_module.id
        )
      end

      if puppet_modules.total > current_user.page_size
        rows += [metadata_row(puppet_modules.total, offset.to_i + rows.length, { :repo_id => @repo.id }, @repo.id)]
      end

      render :json => { :rows => rows, :name => @repo.name }
    end

    def repo_compare_packages
      repo_compare_content(:package, params[:offset] || 0)
    end

    def repo_compare_puppet_modules
      repo_compare_content(:puppet_module, params[:offset] || 0)
    end

    def view_compare_packages
      options = { :unit_type => :package,
                  :cv_env_ids => params[:views].values,
                  :offset => params[:offset].try(:to_i) || 0 }

      render :json => ContentSearch::ContentViewComparison.new(options)
    end

    def view_compare_puppet_modules
      options = { :unit_type => :puppet_module,
                  :cv_env_ids => params[:views].values,
                  :offset => params[:offset].try(:to_i) || 0 }

      render :json => ContentSearch::ContentViewComparison.new(options)
    end

    private

    # TODO: break up this method
    def repo_compare_content(unit_type, offset) # rubocop:disable Metrics/MethodLength
      repo_map = @repos.inject({}) do |map, repo|
        map[repo.pulp_id] = repo
        map
      end

      units = case unit_type
              when :package
                Package.legacy_search('', offset, current_user.page_size,
                               repo_map.keys, [:nvrea_sort, "ASC"], process_search_mode)
              when :puppet_module
                PuppetModule.legacy_search('',  :start => offset, :page_size => current_user.page_size,
                                                :repoids => repo_map.keys, :search_mode => process_search_mode)
              end

      rows = units.collect do |unit|
        cols = {}
        (unit.repoids & repo_map.keys).each do |r|
          cols[repo_map[r].id] = {}
        end

        case unit_type
        when :package
          name = package_display(unit)
          data_type = "package"
        when :puppet_module
          name = puppet_module_display(unit)
          data_type = "puppet_module"
        end

        { :name => name, :id => unit.id, :cols => cols, :data_type => data_type }
      end

      cols = {}

      sort_repos(@repos).each { |r| cols[r.id] = { :id => r.id, :content => repo_compare_name_display(r) } }

      if !units.empty? && units.total > current_user.page_size
        rows += [metadata_row(units.total, offset.to_i + rows.length,
                              { :mode => process_search_mode, :repos => params[:repos] }, 'compare')]
      end

      render :json => { :rows => rows, :cols => cols, :name => _("Repository Comparison") }
    end

    #take in a set of repos and sort based on environment
    def sort_repos(repos)
      env_to_repo = {}
      repos.each do |r|
        env_to_repo[r.environment.id] ||= []
        env_to_repo[r.environment.id] << r
      end

      envs = [current_organization.library] + current_organization.promotion_paths.flatten
      to_ret = []
      envs.each { |e|  to_ret += (env_to_repo[e.id] || []) }
      to_ret
    end

    def find_repos
      @repos = []
      params[:repos].values.each do |item|
        view = ContentView.readable.where(:id => item[:view_id]).first
        library_instance = Repository.find(item[:repo_id])
        @repos += library_instance.environmental_instances(view).select { |r| r.environment_id.to_s == item[:env_id] }
      end
    end

    def find_repo
      @repo = Repository.readable_in_org(current_organization).find(params[:repo_id])
    end

    def repo_hover_html(repo)
      render_to_string :partial => 'repo_hover', :locals => { :repo => repo }
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
      ids = params[type][:autocomplete].collect { |p| p["id"] } if params[type] && params[type][:autocomplete]
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
      conditions = [{ :terms => { :id => readable_list } }]
      conditions << { :terms => { :product_id => product_ids } } unless product_ids.blank?

      #get total repos
      found = Repository.search(:load => true) do
        query { string term,  :default_field => 'name'  } unless term.blank?
        filter "and", conditions
        size 1
      end

      Repository.search(:load => true) do
        query { string term,  :default_field => 'name'  } unless term.blank?
        filter "and", conditions
        size found.total
      end
    end

    def collect_views(view_ids)
      views = ContentView.readable
      views = views.where(:id => view_ids) if view_ids.blank?
      views
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

    def metadata_row(total_count, current_count, data, unique_id, parent_id = nil)
      to_ret = { :total => total_count, :current_count => current_count,
                 :page_size => current_user.page_size, :data => data,
                 :id => "repo_metadata_#{unique_id}", :metadata => true
               }

      to_ret[:parent_id] = parent_id if parent_id
      to_ret
    end

    # TODO: break up method
    # rubocop:disable MethodLength
    def spanned_product_content(view, product, repos, content_type, search_obj, search_mode = nil, environments = nil)
      rows = []
      content_rows = []
      product_envs = {}
      product_envs.default = 0
      accessible_env_ids = KTEnvironment.content_readable(current_organization).pluck("#{Katello::KTEnvironment.table_name}.id")
      search_mode ||= process_search_mode
      environments ||= process_env_ids

      repo_row_hash = ContentSearch::RepoSearch.new(:view => view, :repos => repos).row_object_hash

      repos.each do |repo|
        repo_span = spanned_repo_content(view, repo, content_type,  search_obj, 0, search_mode, environments)
        if repo_span
          rows << repo_row_hash[repo.id]

          repo_span[:repo_cols].values.each do |span|
            product_envs[span[:id]] += span[:display]
          end

          content_rows += repo_span[:content_rows]

          if repo_span[:total] > current_user.page_size
            content_rows << metadata_row(repo_span[:total], current_user.page_size,
                                         { :repo_id => repo.id, :view_id => view.id },
                                         "#{view.id}_#{repo.id}", repo_row_hash[repo.id].id)
          end
        end
      end

      if rows.empty?
        []
      else
        cols = {}
        product_envs.each { |env_id, count| cols[env_id] = { :id => env_id, :display => count } if accessible_env_ids.include?(env_id) }
        [{ :name => product.name, :id => "view_#{view.id}_product_#{product.id}", :parent_id => "view_#{view.id}",
           :cols => cols, :data_type => "product", :value => product.name }] + rows + content_rows
      end
    end

    #Given a repo and a pkg_search (id array or hash),
    #  return a array of {:id => env_id, :display => search.total}
    #
    #
    def spanned_repo_content(view, library_repo, content_type, content_search_obj, offset = 0, search_mode = :all, environments = [])
      spanning_repos = library_repo.environmental_instances(view)
      accessible_env_ids = KTEnvironment.content_readable(current_organization).pluck("#{Katello::KTEnvironment.table_name}.id")

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
      content_class, content_attribute = get_search_info(content_type)
      content = multi_repo_content_search(content_class, content_search_obj, spanning_repos, offset, content_attribute, search_mode)

      return nil if content.total == 0

      spanning_repos.each do |repo|
        results = multi_repo_content_search(content_class, content_search_obj, spanning_repos, offset, content_attribute, search_mode, repo)
        to_ret[repo.environment_id] = { :id => repo.environment_id, :display => results.total } if accessible_env_ids.include?(repo.environment_id)
      end

      { :content_rows => spanning_content_rows(view, content, content_type, library_repo, spanning_repos),
        :repo_cols => to_ret, :total => content.total }
    end

    def get_search_info(content_type)
      if content_type.to_sym == :package
        return Package, 'nvrea'
      else
        return PuppetModule, 'name'
      end
    end

    # perform a content search (errata or package)
    #
    # content_class   either Glue::Pulp::Package or Glue::Pulp::Errata
    # search_obj      either a search string or array of ids
    # repo            repo to search in
    # offset          offset of the search
    # default_field   default field to search if none specifiec
    def  multi_repo_content_search(content_class, search_obj, repos, offset, default_field, search_mode = :all, in_repo = nil)
      user = current_user
      search = Tire::Search::Search.new(content_class.index)

      query_options = {
        :lowercase_expanded_terms => false,
        :default_field            => default_field
      }

      search.instance_eval do
        query do
          if search_obj.is_a?(Array) || search_obj.nil?
            all
          else
            string search_obj, query_options
          end
        end

        sort { by "#{default_field}_sort", 'asc' }
        fields [:id, :name, :nvrea, :repoids, :type, :errata_id, :author, :version]
        size user.page_size
        from offset

        if  search_obj.is_a? Array
          filter :terms, :id => search_obj
        end

        if in_repo
          filter :terms, :repoids => [in_repo.pulp_id]
        end
      end

      repoids = repos.collect { |r| r.pulp_id }
      Util::Package.setup_shared_unique_filter(repoids, search_mode, search)
      search.perform.results

    rescue Tire::Search::SearchRequestFailed
      Util::Support.array_with_total
    end

    # creates rows out of a list of content (Errata or package) for a particular
    #     library repo and its spanning clones across environments
    #
    # content_list   list of package or errata items
    # id_prefix      prefix for the rows (either 'package' or 'errata')
    # parent_repo    the library repo instance (or the parent row)
    # spanned_repos  all other instances of repos across all environments
    def spanning_content_rows(view, content_list, id_prefix, parent_repo, spanned_repos)
      env_ids = KTEnvironment.content_readable(current_organization).pluck("#{Katello::KTEnvironment.table_name}.id")
      to_ret = []
      content_list.each do |item|
        if id_prefix == 'package'
          display = package_display(item)
          value = item.nvrea
        else
          display = puppet_module_display(item)
          value = item.name
        end

        parent_id = "view_#{view.id}_product_#{parent_repo.product.id}_repo_#{parent_repo.id}"
        row = { :id => "#{parent_id}_#{id_prefix}_#{item.id}", :parent_id => parent_id, :cols => {},
                :name => display, :data_type => id_prefix, :value => value }

        spanned_repos.each do |repo|
          if item.repoids.include? repo.pulp_id
            row[:cols][repo.environment_id] = { :id => repo.environment_id } if env_ids.include?(repo.environment_id)
          end
        end

        to_ret << row
      end
      to_ret
    end

    def setup_utils
      ContentSearch::SearchUtils.current_organization = current_organization
      ContentSearch::SearchUtils.current_user = current_user
      ContentSearch::SearchUtils.env_ids = params[:environments]
      ContentSearch::SearchUtils.offset = params[:offset] || 0
      @mode = params[:mode] || 'all'
    end

    def process_views(view_ids)
      views = []

      if view_ids.blank?
        views = ContentView.readable.where(:default => false)
        views << current_organization.default_content_view if Product.readable?
      else
        views = ContentView.readable.where(:id => view_ids)
      end

      views
    end

    def process_products(product_ids)
      products = []

      if product_ids.blank?
        products += current_organization.products.readable.engineering
        products += ContentView.readable_products
      else
        products += current_organization.products.readable.engineering.where(:id => product_ids)
        products += ContentView.readable_products(product_ids)
      end

      products
    end

    def process_repos(repo_ids, product_ids)
      if product_ids.present?
        product_ids = Product.readable.where(:id => product_ids).pluck("#{Katello::Product.table_name}.id")
      end

      # repos were searched by string
      if repo_ids.is_a? Array
        ids = ContentView.readable_repositories(repo_ids).pluck("#{Katello::Repository.table_name}.id")
        ids += Product.readable_repositories(repo_ids).pluck("#{Katello::Repository.table_name}.id")
        repo_ids = ids
      else
        search_string = repo_ids

        repo_ids = []
        repo_ids += ContentView.readable_repositories.pluck(:library_instance_id).uniq
        repo_ids += Product.readable_repositories.pluck("#{Katello::Repository.table_name}.id")
      end

      repo_ids.uniq!
      repo_search(search_string, repo_ids, product_ids)
    end
  end
end
