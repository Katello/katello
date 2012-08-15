require 'test/integration/pulp/vcr_pulp_setup'


module TestPulpPackageBase
  def setup
    @resource = Resources::Pulp::Package
    @repo_url = "http://lzap.fedorapeople.org/fakerepos/zoo5/"
    @repo_name = "integration_test_repo"
    @task = {}
    VCR.insert_cassette('pulp_package')
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
      sleep 0.5 # do not overload backend engines
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


class TestPulpPackage < MiniTest::Unit::TestCase
  include TestPulpPackageBase

  def setup
    super
    create_repo
    sync_repo
  end

  def teardown
    destroy_repo(@repo_name, true)
    super
  end

  def test_package_path
    path = @resource.package_path
    assert_match("/api/packages/", path)
  end

  def test_all
    response = @resource.all
    assert response.length > 0
    assert response.select { |pack| pack['name'] == 'cheetah' }.length > 0
  end

  def test_find
    response = @resource.search('cheetah')
    response = @resource.find(response.first['id'])
    assert response.length > 0
    assert response['name'] == 'cheetah'
  end

  def test_search
    response = @resource.search('cheetah')
    assert response.length > 0
    assert response.first['name'] == 'cheetah'
  end

  def test_name_search
    response = @resource.name_search('cheetah')
    assert response.length > 0
    assert response.include?('cheetah')
  end

  def test_dep_solve
    response = @resource.dep_solve(['cheetah', 'lion'], [@repo_name])
    assert response.length > 0
  end

end
