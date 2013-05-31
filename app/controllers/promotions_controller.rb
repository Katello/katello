#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class PromotionsController < ApplicationController

  before_filter :find_environment
  before_filter :authorize

  def rules
    show_test = lambda {
      to_ret = @environment && (@environment.contents_readable? || @environment.changesets_deletable?)
      to_ret ||=  @next_environment.changesets_readable? if @next_environment
      to_ret
    }

    content_view_test = lambda{ContentView.any_readable?(@environment.organization)}

    prod_test = lambda{
        @environment && @environment.contents_readable? && @product.nil? ? true : @product.provider.readable? }

    {
      :show => show_test,
      :content_views => content_view_test,
      :packages => prod_test,
      :repos => prod_test,
      :errata => prod_test,
      :distributions => prod_test,
    }
  end

  def section_id
    'contents'
  end

  def show
    access_envs = accessible_environments
    setup_environment_selector(current_organization, access_envs)
    @products = @environment.products.readable(current_organization)
    @products = @products.reject{|p| @environment.default_content_view.repos_in_product(@environment, p).empty?}.sort{|a,b| a.name <=> b.name}
    Glue::Pulp::Repos.prepopulate! @products, @environment,[]

    @promotion_changesets = @next_environment.working_promotion_changesets if (@next_environment && @next_environment.changesets_readable?)
    @deletion_changesets = @environment.working_deletion_changesets if (@environment && @environment.changesets_readable?)

    @changeset_product_ids = @changeset.products.collect { |p| p.cp_id } if @changeset
    @changeset_product_ids ||= []
    @locals_hash = {
      :accessible_envs=> access_envs,
      :manage_deletion_changesets => (@environment && @environment.changesets_manageable?)? true : false,
      :manage_promotion_changesets => (@next_environment && @next_environment.changesets_manageable?)? true : false,
      :apply_promotion_changesets => (@next_environment && @next_environment.changesets_promotable?)? true : false,
      :apply_deletion_changesets => (@environment && @environment.changesets_deletable?)? true : false,
      :read_deletion_changesets => (@environment && @environment.changesets_readable?)? true : false,
      :read_promotion_changesets => (@next_environment && @next_environment.changesets_readable?)? true : false,
      :read_contents => (@environment && @environment.contents_readable?)? true: false
    }

    render :show, :locals=>@locals_hash
  end


  # AJAX Calls


  def packages
    product_id = params[:product_id]
    # retrieve the repos associated with the environment's default content view and the specified product
    repos = @environment.default_content_view.repos_in_product(@environment, Product.find(product_id))
    repo_ids = repos.collect{ |repo| repo.pulp_id }

    @promotable_packages = []
    @not_promotable = []

    search = params[:search]
    offset = params[:offset] || 0
    @packages = Package.search(search, params[:offset], current_user.page_size, repo_ids)
    total_count = Product.find(product_id).total_package_count(@environment, @organization.default_content_view)

    render :text=>"" and return if @packages.empty?

    if not @next_environment.nil?
      @packages.each{ |pack|
        promoted = true
        promotable = false
        repos.each{ |repo|
          if pack.repoids.include? repo.pulp_id
            if repo.is_cloned_in? @next_environment
              if pack.repoids.include? repo.clone_id(@next_environment,
                                                     @next_environment.default_content_view)
                promoted = promoted && true
              else
                promotable = true
                promoted = false
              end
            else
              promoted = false
              promotable = promotable || false
            end
          end
        }
        if promotable && !promoted
          @promotable_packages << pack.id
        elsif !promoted && !promotable
          @not_promotable << pack.id
        end
      }
    else
      @not_promotable = @packages.collect{ |pack| pack.id }
    end

    if offset.to_i >  0
      options = {:list_partial => 'promotions/package_items'}
    else
      options = {:list_partial => 'promotions/packages'}
    end

    render_panel_results(@packages, total_count, options)
  end


  def repos
    @next_env_repos = []
    if @next_environment
      @next_environment.default_content_view.repos_in_product(@next_environment, @product).each do |repo|
        @next_env_repos << repo.pulp_id
      end
    end

    offset = params[:offset]
    partial = offset.to_i > 0 ? 'promotions/repo_items' : 'repos'

    filters = [{:product_id=>[@product.id]}, {:default_content_view=>[true]}, {:enabled=>[true]},
               {:environment_id=>[@environment.id]}]

    render_panel_direct(Repository, {:list_partial=>partial}, params[:search],
                        offset, [:name_sort, :ASC], {:default_field => :name, :filter=>filters})
  end

  def errata
    filters = {}
    @promotable_errata = []
    @not_promotable = []

    product_id = params[:product_id]
    if product_id
      # retrieve the repos associated with the environment's default content view and the specified product
      repos = @environment.default_content_view.repos_in_product(@environment, Product.find(product_id))
      repo_ids = repos.collect{ |repo| repo.pulp_id }
      filters[:repoids] = repo_ids
    else
      # retrieve the repos associated with the environment's default content view
      repos = @environment.default_content_view.repos(@environment)
      repo_ids = repos.collect{ |repo| repo.pulp_id }
      filters[:repoids] = repo_ids
    end

    filters = filters.merge(params.slice(:type, :severity).symbolize_keys)

    search = params[:search]
    offset = params[:offset] || 0

    if search.blank?
      @errata = Errata.search(search, offset, current_user.page_size, filters)
      total_size =  @errata.empty? ? 0 :  @errata.total
    else
      @errata = Errata.search(search, offset, current_user.page_size, filters, false)
      all = Errata.search("*", offset, 1, filters, false)
      total_size = all.empty? ? 0 : all.total
    end

    if not @next_environment.nil?
      @errata.each{ |erratum|
        promoted = true
        promotable = false

        repos.each{ |repo|
          if erratum.repoids.include? repo.pulp_id
            if repo.is_cloned_in? @next_environment
              if erratum.repoids.include? repo.clone_id(@next_environment,
                                                        @next_environment.default_content_view)
                promoted = promoted && true
              else
                promotable = true
                promoted = false
              end
            else
              promoted = false
              promotable = promotable || false
            end
          end
        }
        if promotable && !promoted
          @promotable_errata << erratum.id
        elsif !promoted && !promotable
          @not_promotable << erratum.id
        end
      }
    else
      @not_promotable = @errata.collect{ |erratum| erratum.id }
    end

    if offset.to_i >  0
      options = {:list_partial =>'promotions/errata_items'}
    else
      options = {:list_partial =>'errata'}
    end
    #render :partial=>"errata", :locals=>{:collection => @errata}
    render_panel_results(@errata, total_size, options)
  end

  def distributions
    # render the list of distributions

    @distributions = {}
    unless @product.nil?
      @environment.default_content_view.repos_in_product(@environment, @product).each do |repo|
        unless repo.distributions.nil?
          repo.distributions.each{|distro|
            @distributions[distro] = repo
          }
        end
      end
    end
    # sort the results by distro id.  this will order the distros when rendered...
    @distributions.sort_by {|distro, repo| distro.id}

    @next_env_distros = []
    @next_env_repos = []
    if @next_environment
      @next_environment.default_content_view.repos_in_product(@next_environment, @product).each do |repo|
        @next_env_repos << repo.pulp_id
        repo.distributions.each{|distro|
          @next_env_distros << distro.id
        }
      end
    end

    render :partial=>"distributions"
  end

  def content_views
    # render the list of content views
    view_versions = ContentViewVersion.non_default_view.promotable(@environment.organization) || []

    next_env_view_version_ids = @next_environment.nil? ? [].to_set :
                                @next_environment.content_view_versions.non_default_view.
                                pluck("content_view_versions.id").to_set

    render :partial=>"content_views", :locals => {:environment => @environment, :content_view_versions => view_versions,
                                                  :next_env_view_version_ids => next_env_view_version_ids}
  end

  private

  def find_environment
    if current_organization
      @organization = current_organization
      @environment = KTEnvironment.where(:name=>params[:id]).where(:organization_id=>@organization.id).first if params[:id]
      @environment ||= first_env_in_path(accessible_environments, true)
      #raise Errors::SecurityViolation, _("Cannot find a readable environment.") if @environment.nil?

      @next_environment = KTEnvironment.find(params[:next_env_id]) if params[:next_env_id]
      @next_environment ||= @environment.successor if @environment
      @product = Product.find(params[:product_id]) if params[:product_id]
    end
  end

  def accessible_environments
    envs = KTEnvironment.content_readable(current_organization).all
    envs += KTEnvironment.changesets_readable(current_organization).all.map { |env| env.prior if env.prior }.compact
    envs.uniq
  end

end
