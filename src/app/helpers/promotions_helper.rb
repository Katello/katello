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

module PromotionsHelper 

  include ActionView::Helpers::JavaScriptHelper
  include BreadcrumbHelper

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
   
   add_crumb_node!(bc, content_crumb_id, promotion_details_path(@organization.cp_key, @environment.name) ,
       _("Content"), [], {:cache =>true, :content=>render(:partial=>"detail")})
   add_crumb_node!(bc, "all_errata", promotion_errata_path(@organization.cp_key, @environment.name),
       _("All Errata"), [content_crumb_id], {:scrollable=>true})
   add_crumb_node!(bc, products_crumb_id, promotion_products_path(@organization.cp_key, @environment.name),
       _("Products"), [content_crumb_id], {:cache=>true, :content=>render(:partial=>"products", :locals=>{:products=>@products, :changeset=>@changeset})})
       
   for prod in @products
     product_id = product_bc_id(prod)
     #top of this product
     add_crumb_node!(bc, product_id, promotion_details_path(@organization.cp_key, @environment.name, :product_id=>prod.id),
        prod.name, [content_crumb_id,products_crumb_id], {:cache=>true, :content=>render(:partial=>"detail", :locals=>{:product=>prod})})
        
     #product,packages
     add_crumb_node!(bc, packages_bc_id(prod), promotion_packages_path(@organization.cp_key, @environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
        _("Packages"), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true})
        
     #product_errata
     add_crumb_node!(bc, errata_bc_id(prod), promotion_errata_path(@organization.cp_key, @environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
        _("Errata"), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true})

     #product_repos
     add_crumb_node!(bc, repo_bc_id(prod), promotion_repos_path(@organization.cp_key, @environment.name, :product_id=>prod.id, :changeset_id=>changeset_id(@changeset)),
                     _("Repos"), [content_crumb_id,products_crumb_id, product_id], {:scrollable=>true})
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
  
end
