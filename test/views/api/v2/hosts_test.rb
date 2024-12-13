require 'katello_test_helper'

module Katello
  class HostsViewTest < ActiveSupport::TestCase
    def setup
      @host = FactoryBot.build(:host, :with_operatingsystem,
                               :compute_resource_id => compute_resources(:one).id)
    end

    def test_base
      render_rabl('katello/api/v2/hosts/base.json', @host)
    end

    def test_show
      render_rabl('katello/api/v2/hosts/show.json', @host)
    end
  end
end
