module ProductHelperMethods
  def new_test_product_with_locker org

    @locker = KPEnvironment.new
    @locker.locker=true
    @locker.organization = org
    @locker.name = "Locker"
    @locker.stub!(:products).and_return([])
    org.stub!(:locker).and_return(@locker)
    new_test_product org, @locker
  end

  def new_test_product org, env
    disable_product_orchestration
    @provider = Provider.create!({:organization => org, :name => 'provider', :repository_url => "https://something.url", :provider_type => Provider::REDHAT})
    @p = Product.create!(ProductTestData::SIMPLE_PRODUCT.merge!({:environments => [env], :provider => @provider}))
  end


end
