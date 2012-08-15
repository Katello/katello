require 'test/integration/pulp/vcr_pulp_setup'


module TestPulpPackageGroupCategoryBase
  def setup
    @resource = Resources::Pulp::PackageGroupCategory
    @repo_url = "http://lzap.fedorapeople.org/fakerepos/zoo5/"
    @repo_name = "integration_test_repo"
    @task = {}
    VCR.insert_cassette('pulp_package_group_category')
  end

  def teardown
    VCR.eject_cassette
  end

  def create_repo
    Resources::Pulp::Repository.create(:id => @repo_name, :name=> @repo_name, :arch => 'noarch', :feed => @repo_url)
  rescue Exception => e
  end

  def sync_repo
    @task = Resources::Pulp::Repository.sync(@repo_name)
    while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
      @task = Resources::Pulp::Task.find([@task["id"]]).first
      sleep 1 # do not overload backend engines
    end
  end

  def destroy_repo(id=@repo_name, sync=false)
    if sync
      Resources::Pulp::Task.cancel(@task["id"])
      while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
        @task = Resources::Pulp::Task.find([@task["id"]]).first
        sleep 0.5 # do not overload backend engines
      end
    end

    @resource.destroy(id)

  rescue Exception => e
  end

end


class TestPulpPackageGroupCategory < MiniTest::Unit::TestCase
  include TestPulpPackageGroupCategoryBase

  def setup
    super
    create_repo
    sync_repo
  end

  def teardown
    destroy_repo(@repo_name, true)
    super
  end

  def test_path
    path = @resource.path(@repo_name)
    assert_match("/api/repositories/" + @repo_name + "/packagegroupcategories/", path)
  end

  def test_all
    response = @resource.all(@repo_name)
    assert response.length > 0
    assert response.key?('all')
  end

end
