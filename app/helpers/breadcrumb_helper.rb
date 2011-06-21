module BreadcrumbHelper

  def add_crumb_node! hash, id, url, name, trail, params={}
    cache = false || params[:cache] #default to false
    hash[id] = {:name=>name, :url=>url, :trail=>trail, :cache=>cache}
    hash[id][:content] = params[:content] if params[:content]
    hash[id][:scrollable] = true if params[:scrollable]
  end

  def generate_cs_breadcrumb
    bc = {}


    add_crumb_node!(bc, "changesets", unpromoted_changesets_path(), _("Changesets"), [],
                    {:cache =>true, :content=>render(:partial=>"changesets/unpromoted")})

    @changesets.each{|cs|
      add_crumb_node!(bc, changeset_bc_id(cs), products_changeset_path(cs), @changeset.name, ['changesets'],
                    {:cache=>true, :content=>render(:partial=>"changesets/products", :locals=>{:changeset=>cs})})


      

    }     


    bc.to_json
  end

  def changeset_bc_id cs
    "changeset_#{cs.id}" if cs
  end


end