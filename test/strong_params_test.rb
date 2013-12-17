#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello

  class StrongParamsTest < ActiveSupport::TestCase

    def setup
      models = ["Organization", "KTEnvironment", "Product"]
      services = ["Pulp", "ElasticSearch", "Foreman", "Candlepin"]
      disable_glue_layers(services, models)

      @product = katello_products(:fedora)
      @win_params = ActionController::Parameters.new(:name => "Windows XP")
      @ps_params = ActionController::Parameters.new(:name => "Photoshop")
    end

    def teardown
      puts "TEARDOWN"
      Thread.current[:strong_parameters] = nil
    end

    def test_strong_parameters_off
      Thread.current[:strong_parameters] = nil
      assert @product.update_attributes(@win_params)
      assert "Windows XP", @product.reload.name

      Thread.current[:strong_parameters] = false
      assert @product.update_attributes(@ps_params)
      assert "Photoshop", @product.reload.name
    end

    def test_strong_parameters_on
      Thread.current[:strong_parameters] = true
      assert_raises(ActiveModel::ForbiddenAttributes) do
        assert @product.update_attributes(@win_params)
      end
      assert "Fedora", @product.reload.name

      assert @product.update_attributes(@ps_params.permit(:name))
      assert "Photoshop", @product.reload.name

      hostgroup = hostgroups(:db)
      assert hostgroup.update_attributes({:name => "DB"})
      assert_equal hostgroup.reload.name, "DB"
    end

  end
end
