module FiltersHelper

  def objectify filter
    {
        :id => filter.id,
        :products=>[],  # :id
        :repos=>{}   # :product_id=>{:repo_id=>name}
    }
  end


end
