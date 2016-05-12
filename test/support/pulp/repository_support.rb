require 'support/pulp/task_support'

module Katello
  module RepositorySupport
    include TaskSupport
    PULP_TMP_DIR = "/var/lib/pulp/published/puppet_katello_test".freeze
    @repo_url = "file:///var/www/test_repos/zoo"
    @puppet_repo_url = "http://davidd.fedorapeople.org/repos/random_puppet/"
    @repo = nil

    def self.repo_id
      @repo.id
    end

    class << self
      attr_reader :repo
    end

    class << self
      attr_reader :repo_url
    end

    def self.create_and_sync_repo(repo_id)
      @repo = create_repo(repo_id)
      sync_repo
    end

    def self.create_repo(repo_id)
      @repo = Repository.find(repo_id)
      @repo.relative_path = @repo.puppet? ? PULP_TMP_DIR : 'test_path'
      @repo.url = @repo.puppet? ? @puppet_repo_url : @repo_url

      ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Create,
                               content_type: @repo.content_type,
                               pulp_id: @repo.pulp_id,
                               name: @repo.name,
                               feed: @repo.url,
                               unprotected: @repo.unprotected,
                               checksum_type: @repo.checksum_type,
                               path: @repo.relative_path,
                               with_importer: true
                              )

      if @repo.puppet?
        ForemanTasks.sync_task(::Actions::Pulp::Repository::DistributorPublish,
                               :pulp_id => @repo.pulp_id,
                               :distributor_type_id => Runcible::Models::PuppetInstallDistributor.type_id)
      end

      return @repo
    end

    def self.sync_repo
      ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync,
                               pulp_id: @repo.pulp_id
                              )
    end

    def self.destroy_repo(pulp_id = @repo.pulp_id)
      ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Destroy, :pulp_id => pulp_id)
    rescue RestClient::ResourceNotFound => e
      puts "Failed to destroy repo #{e.message}"
    end
  end
end
