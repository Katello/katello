require 'katello_test_helper'
require 'rake'

module Katello
  class SetSubFacetDmiUuidTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/3.15/set_sub_facet_dmi_uuid'
      Rake::Task['katello:upgrades:3.15:set_sub_facet_dmi_uuid'].reenable
      Rake::Task.define_task(:environment)
    end

    def test_set_dmi_uuid
      host = hosts(:one)
      fact_name = RhsmFactName.new(name: 'dmi::system::uuid')
      FactValue.create!(host: host, fact_name: fact_name, value: 'something')

      Rake.application.invoke_task('katello:upgrades:3.15:set_sub_facet_dmi_uuid')

      assert_equal 'something', host.subscription_facet.dmi_uuid
      assert_nil hosts(:two).subscription_facet.dmi_uuid
    end

    def test_no_fact_name
      refute RhsmFactName.find_by_name('dmi::system::uuid')
      assert Rake.application.invoke_task('katello:upgrades:3.15:set_sub_facet_dmi_uuid')
    end

    def test_no_facet
      host = hosts(:without_subscription_facet)

      fact_name = RhsmFactName.new(name: 'dmi::system::uuid')
      FactValue.create!(host: host, fact_name: fact_name, value: 'something')

      assert Rake.application.invoke_task('katello:upgrades:3.15:set_sub_facet_dmi_uuid')
    end
  end
end
