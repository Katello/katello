module FiltersHelper

  def objectify filter
    repos = {}
    filter.repositories.each { |repo|
      repos[repo.product.id.to_s] = [] unless repos[repo.product.id.to_s]
      repos[repo.product.id.to_s] <<  repo.id.to_s
    }

    {
        :id => filter.id,
        :products=>filter.product_ids,  # :id
        :repos=>repos
    }
  end


end
