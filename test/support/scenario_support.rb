require "vcr"
require "active_support/concern"

class ScenarioSupport
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def create_org(org)
    record("support/destroy_org_if_exists") { destroy_org_if_exists(org) }
    record("org_create") { ForemanTasks.sync_task(::Actions::Katello::Organization::Create, org) }
  end

  def destroy_org(org)
    record("organization_destroy") { ForemanTasks.sync_task(::Actions::Katello::Organization::Destroy, org) }
  end

  def create_product(product, org)
    record("product_create") { ForemanTasks.sync_task(::Actions::Katello::Product::Create, product, org, Time.utc(2017, "jan", 1, 20, 15, 1).iso8601) }
  end

  def create_repo(repo)
    record("support/destroy_repo_if_exists") { destroy_repo_if_exists(repo) }
    record("repo_create") { ForemanTasks.sync_task(::Actions::Katello::Repository::Create, repo, false, true) }
  end

  def sync_repo(repo)
    record("repo_sync") { ForemanTasks.sync_task(::Actions::Katello::Repository::Sync, repo) }
  end

  def sleep_if_needed
    sleep 20 if ENV['mode'] == 'all'
  end

  private

  def record(name)
    VCR.insert_cassette("scenarios/#{name}")
    User.current = user
    yield
  rescue
    raise
  ensure
    VCR.eject_cassette
  end

  def destroy_repo_if_exists(repo)
    if exists? { Katello.pulp_server.resources.repository.retrieve(repo.pulp_id) }
      Katello.pulp_server.resources.repository.delete(repo.pulp_id)
    end
  end

  def destroy_org_if_exists(org)
    if org.label
      if exists? { Katello::Resources::Candlepin::Owner.find(org.label) }
        Katello::Resources::Candlepin::Owner.destroy(org.label)
      end
    end
  end

  def exists?
    yield
    true
  rescue RestClient::ResourceNotFound
    false
  end
end
