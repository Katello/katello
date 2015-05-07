require 'katello_test_helper'

module Katello
  class GluePulpUserTest < ActiveSupport::TestCase
    def self.before_suite
      super
      configure_runcible
    end

    def setup
      @user = build(:katello_user, :batman)
    end

    def test_prune_pulp_only_attributes
      attributes = @user.attributes.merge(:backend_attribute_only => "This is a backend only attribute")
      attributes = @user.prune_pulp_only_attributes(attributes)

      refute_includes attributes, :backend_attribute_only
    end
  end
end
