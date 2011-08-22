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

  def generate_cs_breadcrumb
    bc = {}
    add_crumb_node!(bc, "changesets", "", _("Changesets"), [],
                    {:client_render => true})

    @changesets.each{|cs|
      add_crumb_node!(bc, changeset_bc_id(cs), "", cs.name, ['changesets'],
                    {:client_render => true}, {:is_new=>cs.state == Changeset::NEW, :progress => cs.task_status ? cs.task_status.progress : nil})

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
