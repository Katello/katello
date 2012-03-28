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

module BreadcrumbHelper

  def add_crumb_node! hash, id, url, name, trail, params={}, attributes ={}
    cache = false || params[:cache] #default to false
    hash[id] = {:name=>name, :url=>url, :trail=>trail, :cache=>cache}
    hash[id][:content] = params[:content] if params[:content]
    hash[id][:scrollable] = params[:scrollable] ? true : false
    hash[id][:client_render] = true if params[:client_render]
    hash[id][:searchable] = true if params[:searchable]
    hash[id][:product_id] = params[:product_id] if params[:product_id]
    hash[id] = hash[id].merge(attributes)
  end
end

module ChangesetBreadcrumbs
  def generate_cs_breadcrumb
    bc = {}
    add_crumb_node!(bc, "changesets", "", _("Changesets"), [], {:client_render => true})

    @changesets.each{|cs|
      cs_info = {:is_new=>cs.state == Changeset::NEW, :state=>cs.state}
      if (cs.state == Changeset::PROMOTING)
        prog = cs.task_status.progress
        if prog
          cs_info[:progress] =  cs.task_status.progress
        else
          cs_info[:progress] =  0
        end
      end
      add_crumb_node!(bc, changeset_bc_id(cs), "", cs.name, ['changesets'],
                    {:client_render => true}, cs_info)

      cs.involved_products.each{|product|
        #product details
        add_crumb_node!(bc, product_cs_bc_id(cs, product), "", product.name, ['changesets', changeset_bc_id(cs)],
                      {:client_render => true})
        #packages
        add_crumb_node!(bc, packages_cs_bc_id(cs, product), "",  _("Packages"),
                        ['changesets', changeset_bc_id(cs),product_cs_bc_id(cs, product)], {:client_render => true, :product_id => product.id})

        #errata
        add_crumb_node!(bc, errata_cs_bc_id(cs, product), "",  _("Errata"),
                        ['changesets', changeset_bc_id(cs), product_cs_bc_id(cs, product)], {:client_render => true, :product_id => product.id})

        #repos
        add_crumb_node!(bc, repos_cs_bc_id(cs, product), "",  _("Repositories"),
                        ['changesets', changeset_bc_id(cs), product_cs_bc_id(cs, product)], {:client_render => true, :product_id => product.id})

        #repos
        add_crumb_node!(bc, deps_cs_bc_id(cs, product), "",  _("Dependencies"),
                        ['changesets', changeset_bc_id(cs), product_cs_bc_id(cs, product)], {:client_render => true})

        #distributions
        add_crumb_node!(bc, distributions_cs_bc_id(cs, product), "",  _("Distributions"),
                        ['changesets', changeset_bc_id(cs), product_cs_bc_id(cs, product)], {:client_render => true})
      }
    } if @changesets
    bc.to_json
  end

  def changeset_bc_id cs
    "changeset_#{cs.id}" if cs
  end

  def product_cs_bc_id cs, product
    "product-cs_#{cs.id}_#{product.id}" if cs
  end

  def packages_cs_bc_id cs, product
    "package-cs_#{cs.id}_#{product.id}" if cs
  end

  def errata_cs_bc_id cs, product
    "errata-cs_#{cs.id}_#{product.id}" if cs
  end

  def repos_cs_bc_id cs, product
    "repo-cs_#{cs.id}_#{product.id}" if cs
  end

  def deps_cs_bc_id cs, product
    "deps-cs_#{cs.id}_#{product.id}" if cs
  end

  def distributions_cs_bc_id cs, product
    "distribution-cs_#{cs.id}_#{product.id}" if cs
  end

end
  
module ContentBreadcrumbs
  def details_path product_id=nil
    promotion_details_path(@organization.cp_key, @environment.name, :product_id=>product_id)
  end

  #  Generates a json structure of the breadcrumb, consisting of a hash map of:
  #   :id =>  {:url, :name, :trail}   where name is a human readable name, and :trail is
  #                                    a list of other :ids creating the trail leading up to it
  #
  def generate_content_breadcrumb
   bc = {}
   content_crumb_id = "content"
   products_crumb_id = "products"
   templates_crumb_id = "templates"

   errata_crumb_id = "errata"
   errata_filters = errata_bc_filters(@environment.name)

   add_crumb_node!(bc, content_crumb_id, details_promotion_path(@environment.name) ,
       _("Content"), [], {:cache =>true, :content=>render(:partial=>"detail",
                                 :locals=>{:environment_name => @environment.name,
                                           :read_contents => @environment.contents_readable?})})

   add_crumb_node!(bc, errata_crumb_id, nil,
       _("Errata"), [content_crumb_id], {:cache => true, :content => render(:partial => "errata_filters", :locals => {:errata_filters => errata_filters})})

   errata_filters.each do |filter|
     add_crumb_node!(bc, filter[:id], filter[:path],
         filter[:label], [content_crumb_id, errata_crumb_id], {:scrollable=>true, :searchable => true})
   end

   add_crumb_node!(bc, products_crumb_id, products_promotion_path(@environment.name),
       _('Products'), [content_crumb_id], {:cache=>true,
                                           :content=>render(:partial=>"products", :locals=>{:products=>@products, :changeset=>@changeset})},
                                          {:total_size=>@products.length})

   add_crumb_node!(bc, templates_crumb_id, system_templates_promotion_path(@environment.name),
                            _("System Templates"), [content_crumb_id])

   for prod in @products
     product_id = product_bc_id(prod)
     errata_id = errata_bc_id(prod)
     errata_filters = errata_bc_filters(@environment.name, prod)

     #top of this product
     add_crumb_node!(bc, product_id, details_promotion_path(@environment.name, :product_id=>prod.id),
        prod.name, [content_crumb_id,products_crumb_id], {:cache=>true, :product_id => prod.id,
                :content=>render(:partial=>"detail",
                                 :locals=>{:product=>prod, :environment_name => @environment.name,
                                           :read_contents => @environment.contents_readable?})})

     #product_packages
     add_crumb_node!(bc, packages_bc_id(prod), packages_promotion_path(@environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
        _('Packages'), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true, :searchable => true, :product_id => prod.id})

     #product_errata
     add_crumb_node!(bc, errata_id, nil, _('Errata'), [content_crumb_id, products_crumb_id, product_id],
                     {:cache => true, :product_id => prod.id, :content => render(:partial => "errata_filters", :locals => {:errata_filters => errata_filters})})

     errata_filters.each do |filter|
       add_crumb_node!(bc, filter[:id], filter[:path],
           filter[:label], [content_crumb_id, products_crumb_id, product_id, errata_id], {:scrollable=>true, :searchable => true, :product_id => prod.id})
     end

     #product_repos
     add_crumb_node!(bc, repo_bc_id(prod), repos_promotion_path(@environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
                     _("Repos"), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true, :product_id => prod.id})

     #product_distributions
     add_crumb_node!(bc, distribution_bc_id(prod), distributions_promotion_path(@environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
                     _("Distributions"), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true, :product_id => prod.id})
   end

   bc.to_json
  end

  def product_bc_id product
    "details_#{product.id}"
  end

  def packages_bc_id product
    "packages_#{product.id}"
  end

  def errata_bc_id product, filter=nil
    if filter.nil?
      "errata_#{product.id}"
    else
      "errata_#{filter}_#{product.id}"
    end
  end

  def repo_bc_id product
    "repo_#{product.id}"
  end

  def changeset_id cs
    return cs.id if cs
  end

  def distribution_bc_id product
    "distribution_#{product.id}"
  end

  # Create an array of hash elements each containing an id and label for the supported errata filters.  This
  # may be used when building out the breadcrumb and rendering the errata filters.
  def errata_bc_filters env_name, product = nil
    filters = []
    labels = [_("All"), _("Severity: Critical"), _("Severity: Important"), _("Severity: Moderate"),
              _("Severity: Low"), _("Type: Security"), _("Type: Bug Fix"), _("Type: Enhancement")]

    if product.nil?
      filters = [{:id => "errata_all", :label => labels[0], :path => errata_promotion_path(env_name)},
                 {:id => "errata_critical", :label=> labels[1], :path => errata_promotion_path(env_name, :severity => "Critical")},
                 {:id => "errata_important", :label => labels[2], :path => errata_promotion_path(env_name, :severity => "Important")},
                 {:id => "errata_moderate", :label => labels[3], :path => errata_promotion_path(env_name, :severity => "Moderate")},
                 {:id => "errata_low", :label => labels[4], :path => errata_promotion_path(env_name, :severity => "Low")},
                 {:id => "errata_security", :label => labels[5], :path => errata_promotion_path(env_name, :type => "security")},
                 {:id => "errata_bugfix", :label => labels[6], :path => errata_promotion_path(env_name, :type => "bugfix")},
                 {:id => "errata_enhancement", :label => labels[7], :path => errata_promotion_path(env_name, :type => "enhancement")}]
    else
      filters = [{:id => errata_bc_id(product, "all"), :label => labels[0], :path => errata_promotion_path(env_name, :product_id=>product.id, :changeset_id=>changeset_id(@changeset))},
                 {:id => errata_bc_id(product, "critical"), :label => labels[1], :path => errata_promotion_path(env_name, :product_id=>product.id, :changeset_id=>changeset_id(@changeset), :severity => "Critical")},
                 {:id => errata_bc_id(product, "important"), :label => labels[2], :path => errata_promotion_path(env_name, :product_id=>product.id, :changeset_id=>changeset_id(@changeset), :severity => "Important")},
                 {:id => errata_bc_id(product, "moderate"), :label => labels[3], :path => errata_promotion_path(env_name, :product_id=>product.id, :changeset_id=>changeset_id(@changeset), :severity => "Moderate")},
                 {:id => errata_bc_id(product, "low"), :label => labels[4], :path => errata_promotion_path(env_name, :product_id=>product.id, :changeset_id=>changeset_id(@changeset), :severity => "Low")},
                 {:id => errata_bc_id(product, "security"), :label => labels[5], :path => errata_promotion_path(env_name, :product_id=>product.id, :changeset_id=>changeset_id(@changeset), :type => "security")},
                 {:id => errata_bc_id(product, "bugfix"), :label => labels[6], :path => errata_promotion_path(env_name, :product_id=>product.id, :changeset_id=>changeset_id(@changeset), :type => "bugfix")},
                 {:id => errata_bc_id(product, "enhancement"), :label => labels[7], :path => errata_promotion_path(env_name, :product_id=>product.id, :changeset_id=>changeset_id(@changeset), :type => "enhancement")}]
    end
  end
end
  
module RolesBreadcrumbs
  def generate_roles_breadcrumb
    bc = {}

    add_crumb_node!(bc, "roles", "", _(@role.name), [],
                    {:client_render => true},{:locked => @role.locked?})
    add_crumb_node!(bc, "role_permissions", "", _("Permissions"), ['roles'],
                    {:client_render => true})
    add_crumb_node!(bc, "role_users", "", _("Users"), ['roles'],
                    {:client_render => true})
    add_crumb_node!(bc, "global", "", _("Global Permissions"), ['roles', "role_permissions"],
                    {:client_render => true}, { :count => 0, :permission_details => get_global_verbs_and_tags })

    @organizations.each{|org|
      add_crumb_node!(bc, organization_bc_id(org), "", org.name, ['roles', 'role_permissions'],
                    {:client_render => true}, { :count => 0})
    } if @organizations

    User.visible.each{ |user|
      add_crumb_node!(bc, user_bc_id(user), "", user.username, ['roles', 'role_users'],
                    {:client_render => true}, { :has_role => false })
    }

    @role.users.each{ |user|
      bc[user_bc_id(user)][:has_role] = true
    }

    @role.permissions.each{ |perm|
      add_permission_bc(bc, perm, true)
    }

    bc.to_json
  end

  def add_permission_bc bc, perm, adjust_count
    global = perm.resource_type.global?

    type = perm.resource_type
    type_name = type.display_name

    if perm.all_verbs
      verbs = 'all'
    else
      verbs = perm.verbs.collect {|verb| VirtualTag.new(verb.name, verb.all_display_names(perm.resource_type.name)) }
    end

    if perm.all_tags
      tags = 'all'
    else
      tags = perm.tag_values.collect { |t| Tag.formatted(perm.resource_type.name, t) }
    end

    if global
      add_crumb_node!(bc, permission_global_bc_id(perm), "", perm.id, ['roles', 'role_permissions', 'global'],
                  { :client_render => true },
                  { :global => global, :type => type.name, :type_name => type_name,
                    :name => _(perm.name), :description => _(perm.description),
                    :verbs => verbs,
                    :tags => tags })
      if adjust_count
        bc["global"][:count] += 1
      end
    else
      add_crumb_node!(bc, permission_bc_id(perm.organization, perm), "", perm.id, ['roles', 'role_permissions', organization_bc_id(perm.organization)],
                  { :client_render => true },
                  { :organization => "organization_#{perm.organization_id}",
                    :global => global, :type =>  type.name, :type_name => type_name,
                    :name => _(perm.name), :description => _(perm.description),
                    :verbs => verbs,
                    :tags => tags })
      if adjust_count
        bc[organization_bc_id(perm.organization)][:count] += 1
      end
      if type_name == "All"
        if !bc[organization_bc_id(perm.organization)].nil?
          bc[organization_bc_id(perm.organization)][:full_access] = true
        end
      end
    end
  end

  def get_global_verbs_and_tags
    details = {}

    resource_types.each do |type, value|
      details[type] = {}
      details[type][:verbs] = Verb.verbs_for(type, true).collect {|name, display_name| VirtualTag.new(name, display_name)}
      details[type][:verbs].sort! {|a,b| a.display_name <=> b.display_name}
      details[type][:global] = value["global"]
      details[type][:name] = value["name"]
    end

    return details
  end

  def organization_bc_id organization
    if organization
      "organization_#{organization.id}"
    else
      "global"
    end
  end

  def user_bc_id user
    "user_#{user.id}"
  end

  def permission_bc_id organization, permission
    if organization
      "permission_#{organization.id}_#{permission.id}"
    else
      "permission_global_#{permission.id}"
    end
  end

  def permission_global_bc_id permission
    "permission_global_#{permission.id}"
  end
end


module TemplateContentBreadcrumb

  def template_content_breadcrumb
   bc = {}

   products_crumb_id = "products"

   add_crumb_node!(bc, products_crumb_id, "",
       _("Products"), [], {:cache=>true,
                       :content=>render(:partial=>"products", :locals=>{:products=>@products})})

   for prod in @products
     product_id = product_bc_id(prod)
     #top of this product, only need packages for now
     add_crumb_node!(bc, product_id, "",
        prod.name, [products_crumb_id], {:cache=>true, :content=>render(:partial=>"product_detail", :locals=>{:product=>prod})})

     #product.repositories
     add_crumb_node!(bc, repos_bc_id(prod), product_repos_system_templates_path(:product_id=>prod.id),
        _("Repositories"), [products_crumb_id, product_id], {:scrollable=>true})

     #product,packages
     add_crumb_node!(bc, packages_bc_id(prod), product_packages_system_templates_path(:product_id=>prod.id),
        _("Packages"), [products_crumb_id, product_id], {:scrollable=>true, :searchable=>true})

     #product,comps
     add_crumb_node!(bc, comps_bc_id(prod), product_comps_system_templates_path(:product_id=>prod.id),
        _("Package Groups"), [products_crumb_id, product_id], {:scrollable=>true})
   end
   bc.to_json
  end

  def generate_template_breadcrumb
    bc = {}
    root_id = "templates"

    add_crumb_node!(bc, root_id, "", _("Templates"), [],
                    {:client_render => true },
                    {:templates => template_list})

    @templates.each{|template|
      template_id = template_bc_id(template)
      add_crumb_node!(bc, template_id, "", template.name, [root_id], {:client_render => true})

      add_crumb_node!(bc, packages_bc_id(template), "", _("Packages"), [root_id, template_id], {:client_render => true})
      add_crumb_node!(bc, products_bc_id(template), "", _("Products"), [root_id, template_id], {:client_render => true})
      add_crumb_node!(bc, repos_bc_id(template), "", _("Repositories"), [root_id, template_id], {:client_render => true})
      add_crumb_node!(bc, comps_bc_id(template), "", _("Package Groups"), [root_id, template_id], {:client_render => true})
      add_crumb_node!(bc, distro_bc_id(template), "", _("Selected Distribution"), [root_id, template_id], {:client_render => true})
    }

    bc.to_json
  end

  def template_bc_id template
    "details_#{template.id}"
  end

  def packages_bc_id template
    "packages_#{template.id}"
  end

  def comps_bc_id template
    "comps_#{template.id}"
  end

  def repos_bc_id template
    "repos_#{template.id}"
  end

  def product_bc_id product
    "product_#{product.id}"
  end

  def products_bc_id template
    "products_#{template.id}"
  end

  def distro_bc_id template
    "distribution_#{template.id}"
  end

  def template_list
    @templates.collect{|t| {:template_id=>t.id, :template_name=>t.name, :url=>object_system_template_path(t.id)} }
  end
end
