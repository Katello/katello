require 'katello_test_helper'

module Katello
  class LocationTest < ActiveSupport::TestCase
    test 'created location includes some ignored types' do
      loc = Location.create!(:name => "FOO")
      assert_includes loc.ignore_types, ::ProvisioningTemplate.name
      assert_includes loc.ignore_types, ::Hostgroup.name
    end

    context 'default locations' do
      setup do
        set_default_location
      end

      test 'default location for subs or puppet cannot be destroyed' do
        loc = Location.first
        refute_nil loc
        loc.destroy
        refute_empty Location.where(:id => loc.id)
        refute_empty loc.errors.messages
        assert_match(/default.*Location.*subscribed/, loc.errors.full_messages.first)
      end

      test 'default_location_ids returns the ids of the default locations' do
        loc_ids = Location.default_location_ids
        default_location_subs = Location.find_by_title(
          Setting[:default_location_subscribed_hosts])
        default_location_puppet = Location.find_by_title(
          Setting[:default_location_puppet_content])
        refute_nil loc_ids
        assert_equal([default_location_subs.id, default_location_puppet.id].uniq,
                     loc_ids)
      end

      test 'renaming location should update settings' do
        loc = Location.first
        org = Organization.first
        Setting[:default_location_subscribed_hosts] = loc.title
        Setting[:default_location_puppet_content] = loc.title

        loc.organizations << org
        loc.update_attributes!(:name => 'foo_bar')
        assert_equal 'foo_bar', Setting[:default_location_subscribed_hosts]
        assert_equal 'foo_bar', Setting[:default_location_puppet_content]
      end
    end
  end
end
