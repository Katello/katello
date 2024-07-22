require 'katello_test_helper'
require 'rake'

module Katello
  class ReceptorExtractOrgsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/receptor/extract_orgs'
      Rake.application.rake_require 'katello/tasks/reimport' # needed for check_ping
      Rake::Task['katello:receptor:extract_orgs'].reenable
      Rake::Task['katello:check_ping'].reenable
      Rake::Task.define_task(:environment)
      Rake::Task.define_task('dynflow:client')

      Katello::Ping.expects(:ping).returns(:status => 'ok')
    end

    def test_output_file_required
      ENV['OUTPUT_FILE'] = nil
      error = assert_raises(RuntimeError) { Rake.application.invoke_task('katello:receptor:extract_orgs') }
      assert_match(/OUTPUT_FILE/, error.message)
    end

    def test_output_file
      ENV['OUTPUT_FILE'] = Rails.root.join('tmp', 'receptor_orgs.json').to_s

      orgs = Organization.with_upstream_pools
      assert orgs.size > 0 # make sure we are testing something

      orgs.each do |org|
        Katello::Resources::Candlepin::Owner.expects(:find).with(org.label).returns(
          upstreamConsumer: {
            idCert: {
              cert: "#{org.label}_cert",
              key: "#{org.label}_key",
            },
          }
        )
      end

      Rake.application.invoke_task('katello:receptor:extract_orgs')

      data = JSON.parse(File.read(ENV['OUTPUT_FILE']))

      assert_equal orgs.size, data.size

      orgs.each do |org|
        datum = data.find { |d| d['id'] == org.id }

        assert_equal datum['redhat_account_number'], org.redhat_account_number
        assert_equal datum['cert'], "#{org.label}_cert"
        assert_equal datum['key'], "#{org.label}_key"
      end
    end
  end
end
