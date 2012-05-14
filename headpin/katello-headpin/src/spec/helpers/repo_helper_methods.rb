def stub_repos(repos)
  repos.stub(:where => repos)
  Repository.stub_chain(:joins, :where).and_return(repos)
end
