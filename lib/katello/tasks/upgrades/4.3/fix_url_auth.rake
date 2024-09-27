namespace :katello do
  namespace :upgrades do
    namespace '4.3' do
      desc "change urls with username and password in the url to use basic auth parameters in pulp3"
      task :fix_url_auth => ["environment"] do
        User.current = User.anonymous_admin

        Katello::Repository.all.each do |repo|
          upstream_url = repo.root.url
          uri = URI(repo.root.url)
          if uri.userinfo
            user, password = uri.userinfo.split(':')
            upstream_url.slice!(uri.userinfo + "@")
            repo_params = {
              upstream_username: user,
              upstream_password: password,
              url: upstream_url,
            }
            ForemanTasks.sync_task(Actions::Katello::Repository::Update, repo.root, repo_params)
          end
        end
      end
    end
  end
end
