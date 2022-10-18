namespace :katello do
  desc "Check candlepin for missing repository content"
  task :check_candlepin_content => ["environment", "check_ping"] do
    logger = Logger.new(STDOUT)
    User.current = User.anonymous_api_admin
    repos = ::Katello::Repository.yum_type.in_default_view
    bad_repos = repos.reject { |repo| ::Katello::Util::CandlepinRepositoryChecker.repository_exist_in_backend?(repo) }
    logger.info("Checked #{repos.count} repositories.")
    unless bad_repos.blank?
      logger.info("There were #{bad_repos.count} repositories that do not exist in the backend system [Candlepin]")
    end
    bad_repos.each do |repo|
      logger.info("Organization - \"#{repo.organization.name}\", Product - \"#{repo.product.name}\", Repository: \"#{repo.name}\"")
    end
  end
end
