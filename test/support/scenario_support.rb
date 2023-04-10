require "vcr"
require "active_support/concern"

class ScenarioSupport
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def create_org(org)
    record("support/destroy_org_if_exists") { destroy_org_if_exists(org) }
    record("org_create") { Katello::OrganizationCreator.new(org).create! }
  end

  def destroy_org(org, repo)
    ::Katello::Repository.expects(:find).twice.returns(repo)
    record("organization_destroy") { ForemanTasks.sync_task(::Actions::Katello::Organization::Destroy, org) }
  end

  def import_manifest(owner_label, path_to_file)
    filename = path_to_file.split('/').last
    record("import_manifest_#{filename}", match_requests_on: [:method, :path, :params]) do
      path = "/candlepin/owners/#{owner_label}/imports/async?force=SIGNATURE_CONFLICT&force=MANIFEST_SAME"
      client = ::Katello::Resources::Candlepin::CandlepinResource.rest_client(Net::HTTP::Post, :post, path)
      body = {:import => File.new(path_to_file, 'rb')}
      client.post body, {:accept => :json}.merge(User.cp_oauth_header)
    end
  end

  def import_products(org, manifest_path = nil)
    filename = manifest_path&.split('/')&.last
    cassette_name = filename ? "import_products_#{filename}" : "import_products"
    record(cassette_name) do
      org.redhat_provider.import_products_from_cp
    end
  end

  def create_product(product, org)
    Katello::Product.expects(:unused_product_id).returns('7c825013cab01349ae8cb8db187de391')
    record("product_create") { ForemanTasks.sync_task(::Actions::Katello::Product::Create, product, org, Time.utc(2017, "jan", 1, 20, 15, 1).iso8601) }
  end

  def sync_repo(repo)
    record("repo_sync") { ForemanTasks.sync_task(::Actions::Katello::Repository::Sync, repo) }
  end

  def update_repo(repo, params)
    record("repo_update") { ForemanTasks.sync_task(::Actions::Katello::Repository::Update, repo, params) }
  end

  def sleep_if_needed
    sleep 20 if ENV['mode'] == 'all'
  end

  private

  def record(name, options = {})
    VCR.insert_cassette("scenarios/#{name}", options)
    User.current = user
    yield
  rescue
    raise
  ensure
    VCR.eject_cassette
  end

  def destroy_org_if_exists(org)
    Katello::Resources::Candlepin::Owner.destroy(org.label) if org.candlepin_owner_exists?
  end

  def exists?
    yield
    true
  rescue RestClient::ResourceNotFound
    false
  end
end
