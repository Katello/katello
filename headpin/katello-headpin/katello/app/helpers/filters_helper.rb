module FiltersHelper

  def objectify filter
    {
        :id => filter.id,
        :products=>filter.product_ids,  # :id
        :repos=>{}   # :product_id=>{:repo_id=>name}
    }
  end


end
