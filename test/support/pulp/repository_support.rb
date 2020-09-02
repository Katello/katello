require 'support/pulp/task_support'

module Katello
  module RepositorySupport
    extend ActiveSupport::Concern

    included do
      include TaskSupport
      include VCR::TestCase
    end

    PULP_TMP_DIR = "/var/lib/pulp/published/puppet_katello_test".freeze
    @repo_url = "file:///var/lib/pulp/sync_imports/test_repos/zoo"
    @puppet_repo_url = "http://davidd.fedorapeople.org/repos/random_puppet/"
    @repo = nil

    class << self
      attr_reader :repo
    end

    class << self
      attr_reader :repo_url
    end

    def self.create_and_sync_repo(repo)
      create_repo(repo)
      sync_repo(repo)
    end

    def self.create_repo(repo)
      FactoryBot.create(:smart_proxy, :default_smart_proxy) unless ::SmartProxy.pulp_primary

      repo.relative_path = (repo.puppet? ? PULP_TMP_DIR : 'test_path') unless repo.file?
      repo.root.url = (repo.puppet? ? @puppet_repo_url : @repo_url) unless repo.file?
      repo.root.download_policy = :immediate if repo.yum?
      repo.root.save!

      ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Create, repo)
    end

    def self.sync_repo(repo)
      FactoryBot.create(:smart_proxy, :default_smart_proxy) unless ::SmartProxy.pulp_primary

      ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync,
                               repo_id: repo.id
                              )
    end

    def self.destroy_repo(repo)
      FactoryBot.create(:smart_proxy, :default_smart_proxy) unless ::SmartProxy.pulp_primary

      ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Destroy, :repository_id => repo.id, :capsule_id => ::SmartProxy.pulp_primary.id)
    rescue RestClient::ResourceNotFound => e
      puts "Failed to destroy repo #{e.message}"
    end
  end
end
