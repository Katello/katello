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

class SystemTemplatesController < ApplicationController
  include AutoCompleteSearch

  before_filter :setup_options, :only => [:index, :items]
  before_filter :find_template, :only =>[:update, :edit, :destroy, :show, :download, :validate, :object, :update_content]
  before_filter :find_read_only_template, :only =>[:promotion_details]

  def section_id
    'contents'
  end

  def rules
    read_test = lambda{SystemTemplate.readable?(current_organization)}
    manage_test = lambda{SystemTemplate.manageable?(current_organization)}
    {
      :index => read_test,
      :items => read_test,
      :object => read_test,
      :promotion_details => read_test,
      :auto_complete_package => read_test,
      :auto_complete_package_groups => read_test,
      :show => read_test,
      :edit => read_test,
      :download => read_test,
      :validate => read_test,
      :product_repos => read_test,
      :product_packages => read_test,
      :product_comps => read_test,
      :update => manage_test,
      :update_content => manage_test,
      :destroy => manage_test,
      :new => manage_test,
      :create => manage_test,
    }
  end

  def index
    @environment = current_organization.library
    @products = Product.readable(current_organization).joins(:environments).where("environments.id = #{@environment.id}")
    @templates = SystemTemplate.where(:environment_id => current_organization.library.id).limit(current_user.page_size)

    product_hash = {}
    @products.each{|prd|  product_hash[prd.name] = prd.id}

    package_groups = current_organization.library.package_groups.collect{|grp| grp[:name]}.sort

    product_distro_map = {}
    repo_distro_map = {}
    @products.each{|prod|
      product_distro_map[prod.id] = prod.distributions(current_organization.library)

      prod.repos(current_organization.library).each{|repo|
        distros = repo.distributions
        repo_distro_map[repo.id] = distros
      }
    }

    retain_search_history
    render :index, :locals=>{:editable=>SystemTemplate.manageable?(current_organization), :environment => @environment,
                             :product_hash => product_hash, :package_groups => package_groups,
                             :product_distro_map => product_distro_map, :repo_distro_map => repo_distro_map}
  end

  def param_rules
    {
      :create => {:system_template => [:name, :description]},
      :update => {:system_template  => [:name, :description]}
    }
  end


  def setup_options
    @panel_options = { :title => _('System Templates'),
                 :col => ["name"],
                 :titles => [_('Name') ],
                 :create => _('Template'),
                 :create_label => _('+ New Template'),
                 :name => _('template'),
                 :create => _('Template'),
                 :ajax_scroll => items_system_templates_path(),
                 :enable_create => SystemTemplate.manageable?(current_organization) }
  end

  def object
    pkgs = @template.packages.collect{|pkg| {:name=>pkg.package_name}}
    products = @template.products.collect{|prod| {:name=>prod.name, :id=>prod.id}}
    distro = @template.distributions.empty? ? nil : @template.distributions.first.distribution_pulp_id
    repos = @template.repositories.collect{|repo| {:name=>repo.name, :id=>repo.id}}

    # Collect up the environments for all templates with this name
    @templates = SystemTemplate.where(:name => @template.name).joins(:environment).
        where("environments.organization_id =  :org_id", :org_id=>current_organization.id)

    environments = @templates.collect{|template| {:name=>template.environment.name, :id=>template.environment.id}}
    groups = @template.package_groups.collect{|grp| {:name=>grp.name}}

    to_ret = {:id=> @template.id, :name=>@template.name, :description=>@template.description,
              :packages=>pkgs, :products=>products, :repos=>repos, :package_groups=>groups,
              :environments => environments, :distribution=>distro}

    render :json=>to_ret
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout",
           :locals => {:template=>@template,
                       :editable=> SystemTemplate.manageable?(current_organization)}
  end

  def product_packages
    @product = Product.readable(current_organization).find(params[:product_id])
      @packages = []
      @product.repos(current_organization.library).each{|repo|
        repo.packages.each{|pkg|
          @packages << pkg.name
        }
      }

    offset = params[:offset].to_i || 0
    @packages.sort!.uniq!
    total = @packages.length
    options = {:total_count=>@packages.length}
    @packages = @packages[offset..(offset+current_user.page_size-1)]

    if offset >  0
      options[:list_partial]  = 'product_packages_items'
    else
      options[:list_partial] = 'product_packages'
    end
    render_panel_results(@packages, total, options)
  end

  def product_comps
    @product = Product.readable(current_organization).find(params[:product_id])

    @groups = []
    @product.repos(current_organization.library).each{|repo|
      repo.package_groups.each{|grp|
        Rails.logger.error("\n\n\n\n\n") if grp[1].nil?
        Rails.logger.error(grp.inspect) if grp[1].nil?
        Rails.logger.error("\n\n\n\n\n") if grp[1].nil?
        @groups.push(grp["name"])
      }
    }

    @groups = trim @groups

    render :partial=>"product_comps"
  end

  def product_repos
    @product = Product.readable(current_organization).find(params[:product_id])
    render :partial=>"product_repos", :locals => {:current_organization => current_organization.library}
  end

  def update_content

    pkgs = params[:packages]
    products = params[:products]
    pkg_groups = params[:package_groups]
    distro = params[:distribution]
    repos = params[:repos]

    @template.packages.delete_all
    pkgs.each{|pkg|
      @template.packages << SystemTemplatePackage.new(:system_template=>@template, :package_name=>pkg[:name])
    }

    #bz 796239
    #@template.products = []
    #products.each{|prod|
    #  @template.products << Product.readable(current_organization).find(prod[:id])
    #}

    @template.repositories = []
    repos.each{|repo|
      @template.repositories << Repository.readable(current_organization.library).find(repo[:id])
    }

    @template.package_groups = []
    pkg_groups.each{|grp|
      @template.add_package_group(grp[:name])
    }

    if !distro.nil?
      @template.distributions = []
      @template.add_distribution(distro)
    end
    distro_check @template

    @template.save!
    notify.success _("Template %s has been updated successfully") % @template.name
    object()
  end

  def update
    attrs = params[:system_template]
    if attrs[:name]
      result = @template.name = attrs[:name]
    elsif attrs[:description]
      result = @template.description = attrs[:description]
    end
    @template.save!
    notify.success _("Template %s updated successfully.") % @template.name
    render :text=>result
  end

  def destroy
    @template.destroy
    notify.success _("Template '%s' was deleted.") % @template.name
    render :partial => "common/list_remove", :locals => {:id => @template.id, :name=>"details"}
  end

  def show
    render :partial => "common/list_update", :locals=>{:item=>@template, :accessor=>"id", :columns=>['name']}
  end

  def validate
    env_template = SystemTemplate.where(:name => @template.name, :environment_id => params[:environment_id]).first
    env_template.validate_tdl
    render :text=>""
  rescue Errors::TemplateValidationException => e
    notify.exception e
    render :nothing => true, :status => :bad_request
  end

  def download
    # Grab the library template so we can lookup name
    env_template = SystemTemplate.where(:name => @template.name, :environment_id => params[:environment_id]).first
    # Grab the env based on the ID passed in
    environment = KTEnvironment.where(:id=>params[:environment_id]).where(:organization_id=>current_organization.id).first
    # Translate to XML
    xml = env_template.export_as_tdl
    send_data xml,
      :filename => "#{@template.name}-#{environment.name}-export.xml",
      :type => "application/xml"
  end

  def new
    @template = SystemTemplate.new
    render :partial => "new", :layout => "tupane_layout", :locals => {:template => @template}
  end

  def promotion_details
    render :partial => "promotion_details", :layout => "tupane_layout", :locals=>{:template=>@template}
  end

  def create
    obj_params = params[:system_template]
    obj_params[:environment_id] = current_organization.library.id

    @template = SystemTemplate.create!(obj_params)
    notify.success _("System Template '%s' was created.") % @template.name
    render :json=>{:name=>@template.name, :id=>@template.id}
  end

  protected

  #verifies that the distro is in one of the template's products or repositories and gives a warning otherwise
  def distro_check template
    dist = template.distributions.first
    if !dist.nil?
      template.products.each{|prod|
        prod.distributions(current_organization.library).each{|to_check|
          return if dist.distribution_pulp_id == to_check.id
        }
      }
      template.repositories.each{|repo|
        repo.distributions.each{|to_check|
          return if dist.distribution_pulp_id == to_check.id
        }
      }
      #not found
      template.distributions = []
      notify.warning _("Template '%s' has been updated successfully, however you have removed either "+
                           "a product or repository that contained the selected distribution for this template.  " +
                           "Please select another distribution to ensure a working system template.") % @template.name
    end
  end

  def find_read_only_template
    @template = SystemTemplate.find(params[:id])
  end

  def find_template
    find_read_only_template
    if !@template.environment.library?
      msg = _("Cannot modify a template that is another environment")
      notify.error msg
      render :text => msg, :status => :bad_request
      return
    end
  end

  def trim list
    list.sort!.uniq!
    offset = params[:offset].to_i if params[:offset]

    if offset
      list = list[offset..offset+current_user.page_size]
      render :text=>"" and return if list.empty?
    else
      list = list[0..current_user.page_size]
    end
    list
  end

end
