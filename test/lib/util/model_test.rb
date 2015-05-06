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
