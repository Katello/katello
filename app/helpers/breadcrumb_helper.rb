module BreadcrumbHelper

  def add_crumb_node! hash, id, url, name, trail, params={}
    cache = false || params[:cache] #default to false
    hash[id] = {:name=>name, :url=>url, :trail=>trail, :cache=>cache}
    hash[id][:content] = params[:content] if params[:content]
    hash[id][:scrollable] = true if params[:scrollable]
    hash[id][:client_render] = true if params[:client_render]
  end

  def generate_cs_breadcrumb
    bc = {}


    add_crumb_node!(bc, "changesets", unpromoted_changesets_path(), _("Changesets"), [],
                    {:client_render => true})




    @changesets.each{|cs|
      add_crumb_node!(bc, changeset_bc_id(cs), products_changeset_path(cs), cs.name, ['changesets'],
                    {:cache=>true, :content=>render(:partial=>"changesets/products", :locals=>{:changeset=>cs})})

      cs.involved_products.each{|product|
        #product details 
        add_crumb_node!(bc, product_cs_bc_id(cs, product), "url", product.name, ['changesets', changeset_bc_id(cs)],
                      {:cache=>true, :content=>render(:partial=>"changesets/product", :locals=>{:product=>product, :changeset=>cs})})
        #packages
        add_crumb_node!(bc, packages_cs_bc_id(cs, product), packages_changeset_path(cs, {:product_id => product.id}),  _("Packages"),
                        ['changesets', changeset_bc_id(cs),product_cs_bc_id(cs, product)])




      }
      

    } if @changesets


    bc.to_json
  end

  def changeset_bc_id cs
    "changeset_#{cs.id}" if cs
  end

  def product_cs_bc_id cs, product
    "product_cs_#{product.id}_#{cs.id}" if cs
  end

  def packages_cs_bc_id cs, product
    "packages-cs_#{product.id}_#{cs.id}" if cs
  end


end