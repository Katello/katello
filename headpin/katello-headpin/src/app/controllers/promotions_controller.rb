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

class PromotionsController < ApplicationController

  skip_before_filter :authorize #load the environment
  before_filter :find_environment
  before_filter :authorize

  def rules
    show_test = lambda {
      to_ret = @environment && @environment.contents_readable?
      to_ret ||=  @next_environment.changesets_readable? if @next_environment
      to_ret
    }

    prod_test = lambda{ @environment.contents_readable? and @product.nil? ? true : @product.provider.readable? }
    {
      :show => show_test,
      :system_templates => lambda{true},
      :packages => prod_test,
      :repos => prod_test,
      :errata => prod_test,
      :distributions => prod_test
    }
  end



  def section_id
    'contents'
  end

  def show
    access_envs = accessible_environments
    setup_environment_selector(current_organization, access_envs)
    @products = @environment.products.readable(current_organization)
    @products = @products.reject{|p| p.repos(@environment).empty?}.sort{|a,b| a.name <=> b.name}
    

    @changesets = @next_environment.working_changesets if (@next_environment && @next_environment.changesets_readable?)
    @changeset_product_ids = @changeset.products.collect { |p| p.cp_id } if @changeset
    @changeset_product_ids ||= []
    locals = {
      :accessible_envs=> access_envs,
      :manage_changesets => @next_environment.nil? ? false : @next_environment.changesets_manageable?,
      :promote_changesets => @next_environment.nil? ? false : @next_environment.changesets_promotable?,
      :read_changesets => @next_environment.nil? ? false : @next_environment.changesets_readable?,
      :read_contents => (@environment && @environment.contents_readable?)? true: false
    }
    
    render :show, :locals=>locals
  end




  # AJAX Calls

  def packages
      package_hash = {}
      @product.repos(@environment).each{|repo|
        repo.packages.each{|pkg|
          package_hash[pkg.id] = pkg if package_hash[pkg.id].nil?
        }
      }

     @next_env_pkgs = []
     if @next_environment
       @product.repos(@next_environment).each{|repo|
          repo.packages.each{|pkg|
            @next_env_pkgs << pkg.id
          }
        }
     end

      @packages = package_hash.values
      @packages.sort! {|a,b| a.nvrea <=> b.nvrea}
      offset = params[:offset]
      offset = offset.to_i if offset
      if offset
        @packages = @packages[offset..offset+current_user.page_size] || []
        render :text=>"" and return if @packages.empty?
        render :partial=>"package_items" and return
      else
        @packages = @packages[0..current_user.page_size]
      end

      render :partial=>"packages"
  end


  def repos
    @repos = @product.repos(@environment)
    offset = params[:offset]
    if offset
      @repos = @repos[offset..offset+current_user.page_size]
      render :text=>"" and return if @repos.empty?
    else
      @repos = @repos[0..current_user.page_size]
    end

    @next_env_repos = []
     if @next_environment
       @product.repos(@next_environment).each{|repo|
          @next_env_repos << repo.id
        }
     end
    render :partial=>"repos"
  end

  def errata
    filter = params.slice(:type, :severity).symbolize_keys
    filter[:environment_id] = @environment.id
    filter[:product_id] = @product.cp_id unless @product.nil?

    @errata = Glue::Pulp::Errata.filter(filter)
    @errata.sort! {|a,b| a['title'] <=> b['title']}

    offset = params[:offset]
    if offset
      offset = offset.to_i
      @errata = @errata[offset..offset+current_user.page_size]
      render :text=>"" and return if @errata.empty?
      render :partial=>"errata_items" and return 
    else
      @errata = @errata[0..current_user.page_size]
    end
    render :partial=>"errata"
  end

  def distributions
    # render the list of distributions

    @distributions = {}
    unless @product.nil?
      @product.repos(@environment).each do |repo|
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
      @product.repos(@next_environment).each{|repo|
        @next_env_repos << repo.id
        repo.distributions.each{|distro|
          @next_env_distros << distro.id
        }
      }
    end

    render :partial=>"distributions"
  end
  

  def system_templates
    # render the list of system_templates
    render :partial=>"system_templates", :locals => {:system_templates => templates}
  end


  private

  def find_environment
    @organization = current_organization
    @environment = KTEnvironment.where(:name=>params[:id]).where(:organization_id=>@organization.id).first if params[:id]
    @environment ||= first_env_in_path(accessible_environments, true)
    #raise Errors::SecurityViolation, _("Cannot find a readable environment.") if @environment.nil?

    @next_environment = KTEnvironment.find(params[:next_env_id]) if params[:next_env_id]
    @next_environment ||= @environment.successor if @environment
    @product = Product.find(params[:product_id]) if params[:product_id]
  end

  def accessible_environments
    list = KTEnvironment.content_readable(current_organization)
    KTEnvironment.changesets_readable(current_organization).each{|env|
      list << env.prior if env.prior
    }
    list.uniq
  end


  def templates
    @environment.system_templates || []
  end
  helper_method :templates

end
