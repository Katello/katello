module ProductHelperMethods

  
  
  def new_test_product_with_locker org

    @locker = KTEnvironment.new
    @locker.locker = true
    @locker.organization = org
    @locker.name = "Locker"
    @locker.stub!(:products).and_return([])
    org.stub!(:locker).and_return(@locker)
    new_test_product org, @locker
  end

  def new_test_product org, env, suffix=""
    disable_product_orchestration
    @provider = Provider.create!({:organization => org, :name => 'provider' + suffix, :repository_url => "https://something.url", :provider_type => Provider::CUSTOM})
    @p = Product.create!(ProductTestData::SIMPLE_PRODUCT.merge!({:name=>'product' + suffix, :environments => [env], :provider => @provider}))
    repo = Glue::Pulp::Repo.new(:name=>"FOOREPO", :id=>"anid")
    pkg = Glue::Pulp::Package.new(:name=>"Pkg", :id=>"234")
    repo.stub(:packages).and_return([pkg])

    errata = Glue::Pulp::Errata.new(:title=>"Errata", :id=>"1235")
    repo.stub(:errata).and_return([errata])
    distribution = Glue::Pulp::Distribution.new()
    repo.stub(:distributions).and_return([distribution])

    @p.stub(:repos).and_return([repo])
    @p

  end


end
