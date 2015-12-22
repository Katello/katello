require 'katello_test_helper'

module Katello
  class LocationTest < ActiveSupport::TestCase
    def setup
      set_default_location
    end

    def test_location_create
      loc = Location.create!(:name => "FOO")
      assert_includes loc.ignore_types, ::ProvisioningTemplate.name
      assert_includes loc.ignore_types, ::Hostgroup.name
    end

    def test_default_destroy
      loc = Location.default_location

      refute_nil loc
      loc.destroy
      refute_empty Location.where(:id => loc.id)
      refute_empty loc.errors.messages
    end

    def test_update_katello_default
      loc = Location.default_location
      loc.katello_default = false

      assert_raises(RuntimeError) do
        loc.save!
      end
    end
  end
end
