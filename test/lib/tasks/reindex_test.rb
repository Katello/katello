require 'katello_test_helper'
require 'rake'

module Katello
  class ReindexHelperTest < ActiveSupport::TestCase
    let(:system) { katello_systems(:simple_server) }

    setup do
      Rake.application.rake_require 'katello/tasks/reindex'
      @exception = StandardError.new('Custom Error Message')
      @exception.set_backtrace('Backtrace')
      system.stubs(:pulp_facts).returns('some_facts')
      @reindex_helper = ReindexHelper.new
    end

    def teardown
      system.destroy
    end

    describe 'Report Bad Objects' do
      test 'runs and acknowledges messages when candlepin return empty response for given uuid' do
        Katello::Resources::Candlepin::Consumer.expects(:get).with(system.uuid).returns(nil)
        @reindex_helper.report_bad_objects([[system, @exception]], Katello::System)
      end

      test 'runs and should not print any message when candlepin return valid response for given system uuid' do
        Katello::Resources::Candlepin::Consumer.expects(:get).with(system.uuid).returns(true)
        @reindex_helper.report_bad_objects([[system, @exception]], Katello::System)
      end
    end
  end
end
