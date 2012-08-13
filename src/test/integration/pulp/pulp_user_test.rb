require 'test/integration/pulp/vcr_pulp_setup'


class TestPulpUser < MiniTest::Unit::TestCase
  def setup
    VCR.insert_cassette('pulp_user')
    @username = "admin"
    @resource = Resources::Pulp::User
  end

  def teardown
    VCR.eject_cassette
  end

  def test_path_without_username
    path = @resource.path
    assert_match("/api/users/", path)
  end

  def test_path_with_username
    path = @resource.path(@username)
    assert_match("/api/users/" + @username, path)
  end

  def test_find
    response = @resource.find(@username)
    assert response.length > 0
    assert(@username, response["login"])
  end

  def test_create
    response = @resource.create(:login => "integration_test_user", :name => "integration_test_user", :password => "integration_test_password")
    assert response.length > 0
    @resource.destroy("integration_test_user")
  end

  def test_destroy
    @resource.create(:login => "integration_test_user", :name => "integration_test_user", :password => "integration_test_password")
    response = @resource.destroy("integration_test_user")
    assert response == 200
  end

end
