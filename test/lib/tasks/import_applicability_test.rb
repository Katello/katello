require 'katello_test_helper'
require 'rake_test_helper'
require 'rake'

module Katello
  class ImportApplicabilityTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/import_applicability'
      Rake::Task['katello:import_applicability'].reenable
      Rake::Task.define_task(:environment)
    end

    def test_success
      Katello::Host::ContentFacet.any_instance.expects(:calculate_and_import_applicability).at_least_once

      Rake.application.invoke_task('katello:import_applicability')
    end
  end
end
