require 'test/integration/pulp/vcr_pulp_setup'


class TestPulpPing < MiniTest::Unit::TestCase
  def setup
    VCR.insert_cassette('pulp_ping')
  end

  def teardown
    VCR.eject_cassette
  end

  def test_ping
    response = Resources::Pulp::PulpPing.ping()
    assert response.length > 0
  end
end
