module RepositoryHelperMethods

  def stub_repos(repos)
    repos.stub(:where => repos)
    Repository.stub_chain(:joins, :where).and_return(repos)

    Product.instance_eval do
      define_method(:repos) do |env|
        repos
      end
    end
  end

  def new_test_repo(env, product, name, path, enabled=true, suffix="", library_instance=nil)
    disable_repo_orchestration
    disable_product_orchestration

    random_id = rand(10**6)
    repo = Repository.new(:environment => env, :product => product,
                          :name => name, :label =>  "#{name}-#{random_id}",
                          :relative_path => path, :pulp_id => "pulp-id-#{random_id}",
                          :content_id => "content-id-#{random_id}", :enabled => enabled,
                          :content_view_version=>env.default_content_view_version,
                          :feed=>'http://localhost.com/foo')
    repo.library_instance = library_instance if library_instance
    repo.stub(:create_pulp_repo).and_return([])
    repo.save!
    repo
  end

end
