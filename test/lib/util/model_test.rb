#
# Copyright 2014 Red Hat, Inc.
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
  module Util
    class ModelTest < ActiveSupport::TestCase

      test "should return controller path for given model" do
        assert_equal Katello::Util::Model.model_to_controller_path(Katello::ActivationKey), "katello/activation_keys"
        assert_equal Katello::Util::Model.model_to_controller_path(Katello::KTEnvironment), "katello/environments"
      end

      test "should return model for given controller path" do
        assert_equal Katello::Util::Model.controller_path_to_model("katello/activation_keys"), Katello::ActivationKey
        assert_equal Katello::Util::Model.controller_path_to_model("katello/environments"), Katello::KTEnvironment
      end
    end
  end
end
