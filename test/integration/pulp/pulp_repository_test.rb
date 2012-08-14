require 'test/integration/pulp/vcr_pulp_setup'
require 'active_support/core_ext/time/calculations'

module TestPulpRepositoryBase
  def setup
    @resource = Resources::Pulp::Repository
    @repo_url = "http://lzap.fedorapeople.org/fakerepos/zoo5/"
    @repo_name = "integration_test_repo"
    @task = {}
    VCR.insert_cassette('pulp_repository')
  end

  def teardown
    VCR.eject_cassette
  end

  def create_repo
    @resource.create(:id => @repo_name, :name=> @repo_name, :arch => 'noarch', :feed => @repo_url)
  end

  def sync_repo
    response = @resource.sync(@repo_name)
    @task = response

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

class TestPulpRepositoryCreate < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase

  def teardown
    destroy_repo
    super
  end

  def test_create
    response = @resource.create(:id => @repo_name, :name=> @repo_name, :arch => 'noarch', :feed => @repo_url)
    assert response.length > 0
    assert response['id'] == "integration_test_repo"
  end
end

class TestPulpRepository < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase

  def setup
    super
    create_repo
  end

  def teardown
    destroy_repo
    super
  end

  def test_repository_path
    path = @resource.repository_path
    assert_match("/api/repositories/", path)
  end

  def test_discovery
    response = @resource.start_discovery(@repo_url, 'yum')
    assert response.length > 0
  end

  def test_find
    response = @resource.find(@repo_name)
    assert response.length > 0
    assert response["name"] == @repo_name
  end

  def test_find_all
    response = @resource.find_all([@repo_name])
    assert response.length > 0
    assert response["name"] == @repo_name
  end

  def test_all
    response = @resource.all()
    assert response.length > 0
    assert response.select { |r| r["name"] == @repo_name }.length > 0
  end

  def test_update
    response = @resource.update(@repo_name, { :name => "updated_" + @repo_name })
    assert response.length > 0
    assert response["name"] == "updated_" + @repo_name
  end

  def test_update_schedule
    response = @resource.update_schedule(@repo_name, "R1/" << Time.now.advance(:years => 1).iso8601 << "/P1D")
    assert response.length > 0
    assert response["id"] == @repo_name
    @resource.delete_schedule(@repo_name)
  end

  def test_delete_schedule
    @resource.update_schedule(@repo_name, "R1/" << Time.now.advance(:years => 1).iso8601 << "/P1D")
    response = @resource.delete_schedule(@repo_name)
    assert response.length > 0
    assert response["id"] == @repo_name
  end

  def test_destroy
    response = @resource.destroy(@repo_name)
    assert response == 202
  end
end

class TestPulpRepositoryRequiresSync < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase

  def setup
    super
    create_repo
    clone_repo
  end

  def teardown
    destroy_repo
    super
  end

  def test_packages
    response = @resource.packages(@repo_name)
    assert response.length > 0
  end

  def test_packages_by_name
    response = @resource.packages_by_name(@repo_name, "cheetah")
    assert response.length > 0
    assert response.select { |r| r["name"] == "cheetah" }.length > 0
  end

  def test_packages_by_nvre
    response = @resource.packages_by_nvre(@repo_name, "cheetah", "0.3", "0.8", "")
    assert response.length > 0
    assert response.select { |r| r["name"] == "cheetah" }.length > 0
  end

  def test_errata
    response = @resource.errata(@repo_name)
    assert response.length > 0
  end

  def test_errata_with_filter
    response = @resource.errata(@repo_name, { :type => 'security' })
    assert response.length > 0
    assert response['id'] == "RHEA-2010:0002"
  end
end

class TestPulpRepositorySync < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase

  def setup
    super
    destroy_repo(@repo_name)
    create_repo
  end

  def teardown
    destroy_repo(@repo_name, true)
    super
  end

  def test_sync_repo
    response = @resource.sync(@repo_name)
    @task = response
    assert response.length > 0
    assert response["method_name"] == "_sync"
  end

  def test_sync_status
    task = @resource.sync(@repo_name)
    response = @resource.sync_status(@repo_name)
    debugger
    assert response.length > 0
    assert response.first['id'] == task['id']
  end
end

class TestPulpRepositoryClone < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase

  def setup
    super
    destroy_repo(@repo_name)
    create_repo
    @clone_name = @repo_name + "_clone"
  end

  def teardown
    destroy_repo(@clone_name, true)
    destroy_repo(@repo_name)
    super
  end

  def test_clone_repo
    destroy_repo(@clone_name)
    from_repo = OpenStruct.new({ :pulp_id => @repo_name })
    to_repo = OpenStruct.new({ :pulp_id => @clone_name, :name => @clone_name })
    response = @resource.clone_repo(from_repo, to_repo)
    @task = response
    assert response.length > 0
    assert response["args"].include?(@clone_name)
  end
end
