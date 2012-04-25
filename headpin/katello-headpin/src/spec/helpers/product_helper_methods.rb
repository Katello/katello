module ProductHelperMethods



  def new_test_product_with_library org

    @library = KTEnvironment.new
    @library.library = true
    @library.organization = org
    @library.name = "Library"
    @library.stub!(:products).and_return([])
    org.stub!(:library).and_return(@library)
    new_test_product org, @library
  end

  def new_test_product org, env, suffix=""
    disable_product_orchestration
    disable_repo_orchestration
    @provider = Provider.create!({:organization => org, :name => 'provider' + suffix, :repository_url => "https://something.url", :provider_type => Provider::CUSTOM})
    @p = Product.create!(ProductTestData::SIMPLE_PRODUCT.merge({:name=>'product' + suffix, :environments => [env], :provider => @provider}))
    env_product = EnvironmentProduct.find_or_create(env, @p)
    repo = Repository.create!(:environment_product => env_product, :name=>"FOOREPO", :pulp_id=>"anid")
    pkg = Glue::Pulp::Package.new(:name=>"Pkg", :id=>"234")
    repo.stub(:packages).and_return([pkg])

    errata = Glue::Pulp::Errata.new(:title=>"Errata", :id=>"1235")
    repo.stub(:errata).and_return([errata])
    Glue::Pulp::Errata.stub!(:filter).and_return([:errata])
    distribution = Glue::Pulp::Distribution.new()
    repo.stub(:distributions).and_return([distribution])

    @p.stub(:repos).and_return([repo])
    @p

  end


  def promote repo, environment
    disable_product_orchestration
    repo.stub!(:pulp_repo_facts).and_return({:clone_ids => []})
    Pulp::Repository.stub!(:clone_repo).and_return({})
    Glue::Pulp::Repos.stub!(:groupid).and_return([])
    repo.stub(:content => {:id => "123"})
    repo.promote(environment.prior, environment)
    ep = EnvironmentProduct.find_or_create(environment, repo.product)
    Repository.where(:environment_product_id => ep).first
  end


end
