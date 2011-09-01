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
    hash[id][:scrollable] = true if params[:scrollable]
    hash[id][:client_render] = true if params[:client_render]
    hash[id] = hash[id].merge(attributes)
  end

  module ChangesetBreadcrumbs
    def generate_cs_breadcrumb
      bc = {}
      add_crumb_node!(bc, "changesets", "", _("Changesets"), [], {:client_render => true})
  
      @changesets.each{|cs|
        add_crumb_node!(bc, changeset_bc_id(cs), "", cs.name, ['changesets'],
                      {:client_render => true}, {:is_new=>cs.state == Changeset::NEW})
  
        cs.involved_products.each{|product|
          #product details 
          add_crumb_node!(bc, product_cs_bc_id(cs, product), "", product.name, ['changesets', changeset_bc_id(cs)],
                        {:client_render => true})
          #packages
          add_crumb_node!(bc, packages_cs_bc_id(cs, product), "",  _("Packages"),
                          ['changesets', changeset_bc_id(cs),product_cs_bc_id(cs, product)], {:client_render => true})
  
          #errata
          add_crumb_node!(bc, errata_cs_bc_id(cs, product), "",  _("Errata"),
                          ['changesets', changeset_bc_id(cs), product_cs_bc_id(cs, product)], {:client_render => true})
  
          #repos
          add_crumb_node!(bc, repos_cs_bc_id(cs, product), "",  _("Repositories"),
                          ['changesets', changeset_bc_id(cs), product_cs_bc_id(cs, product)], {:client_render => true})
  
          #repos
          add_crumb_node!(bc, deps_cs_bc_id(cs, product), "",  _("Dependencies"),
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
     
     add_crumb_node!(bc, content_crumb_id, details_promotion_path(@environment.name) ,
         _("Content"), [], {:cache =>true, :content=>render(:partial=>"detail")})
     add_crumb_node!(bc, "all_errata", errata_promotion_path(@environment.name),
         _("All Errata"), [content_crumb_id], {:scrollable=>true})
     add_crumb_node!(bc, products_crumb_id, products_promotion_path(@environment.name),
         _("Products"), [content_crumb_id], {:cache=>true, :content=>render(:partial=>"products", :locals=>{:products=>@products, :changeset=>@changeset})})
         
     for prod in @products
       product_id = product_bc_id(prod)
       #top of this product
       add_crumb_node!(bc, product_id, details_promotion_path(@environment.name, :product_id=>prod.id),
          prod.name, [content_crumb_id,products_crumb_id], {:cache=>true, :content=>render(:partial=>"detail", :locals=>{:product=>prod})})
          
       #product,packages
       add_crumb_node!(bc, packages_bc_id(prod), packages_promotion_path(@environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
          _("Packages"), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true})
          
       #product_errata
       add_crumb_node!(bc, errata_bc_id(prod), errata_promotion_path(@environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
          _("Errata"), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true})
  
       #product_repos
       add_crumb_node!(bc, repo_bc_id(prod), repos_promotion_path(@environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
                       _("Repos"), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true})

     #product_distributions
     add_crumb_node!(bc, distribution_bc_id(prod), distributions_promotion_path(@environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
                     _("Distributions"), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true})
              
     end
     bc.to_json
    end
  
    def product_bc_id product
      "details_#{product.id}"
    end
    
    def packages_bc_id product
      "packages_#{product.id}"
    end
    
    def errata_bc_id product
      "errata_#{product.id}"
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

  end
  
  module RolesBreadcrumbs
    def generate_roles_breadcrumb
      bc = {}
      add_crumb_node!(bc, "roles", "", _(@role.name), [],
                      {:client_render => true})
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
      
      User.all.each{ |user|
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
      type = perm.resource_type.display_name
      if global
        add_crumb_node!(bc, permission_global_bc_id(perm), "", perm.id, ['roles', 'role_permissions', 'global'],
                    { :client_render => true }, 
                    { :global => global, :type => type,
                      :name => perm.name, :description => perm.description, 
                      :verbs => perm.verbs.collect {|verb| VirtualTag.new(verb.name, verb.display_name(perm.resource_type.name, global))}, 
                      :tags => perm.tags.collect { |t| t.formatted(perm.resource_type.name) }})
        if adjust_count
          bc["global"][:count] += 1
        end
      else
        add_crumb_node!(bc, permission_bc_id(perm.organization, perm), "", perm.id, ['roles', 'role_permissions', organization_bc_id(perm.organization)],
                    { :client_render => true }, 
                    { :organization => "organization_#{perm.organization_id}", 
                      :global => global, :type =>  type,
                      :name => perm.name, :description => perm.description, 
                      :verbs => perm.verbs.collect {|verb| VirtualTag.new(verb.name, verb.display_name(perm.resource_type.name, global))}, 
                      :tags => perm.tags.collect { |t| t.formatted(perm.resource_type.name) }})
        if adjust_count
          bc[organization_bc_id(perm.organization)][:count] += 1
        end
        if type == "All"
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
       #add_crumb_node!(bc, product_id, "",
       #   prod.name, [products_crumb_id], {:cache=>true, :content=>render(:partial=>"product_detail", :locals=>{:product=>prod})})

       #product,packages
       add_crumb_node!(bc, packages_bc_id(prod), packages_promotion_path(@environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
          prod.name + " " +  _("Packages"), [products_crumb_id], {:scrollable=>true})
          

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
      }

      bc.to_json
    end


    def template_bc_id template
      "details_#{template.id}"
    end

    def packages_bc_id template
      "packages_#{template.id}"
    end

    def products_bc_id template
      "products_#{template.id}"
    end

    def template_list
      @templates.collect{|t| {:template_id=>t.id, :template_name=>t.name, :url=>object_system_template_path(t.id)} }
    end

  end


end
