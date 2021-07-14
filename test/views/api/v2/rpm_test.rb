require 'katello_test_helper'

module Katello
  class RpmViewTest < ActiveSupport::TestCase
    def setup
      @rpm = katello_rpms(:two)
    end

    def test_base
      assert_service_not_used(Pulp3::Rpm) do
        render_rabl('katello/api/v2/packages/base.json', @rpm)
      end
    end

    def test_show
      Pulp3::Rpm.any_instance.expects(:backend_data).at_least_once.returns({ 'files' => [] })
      render_rabl('katello/api/v2/packages/show.json', @rpm)
    end
  end
end
