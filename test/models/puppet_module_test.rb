require 'katello_test_helper'

module Katello
  class PuppetModuleTest < ActiveSupport::TestCase
    def test_parse_metadata
      filepath = File.join(Katello::Engine.root, "test/fixtures/puppet/puppetlabs-ntp-2.0.1.tar.gz")
      metadata = PuppetModule.parse_metadata(filepath)

      assert_equal "Puppet Labs", metadata[:author]
      assert_equal "puppetlabs-ntp", metadata[:name]
      assert_equal "2.0.1", metadata[:version]
      assert_equal "NTP Module", metadata[:summary]
    end

    def test_parse_metadata_with_bad_file
      filepath = __FILE__
      assert_raises(Katello::Errors::InvalidPuppetModuleError) do
        PuppetModule.parse_metadata(filepath)
      end
    end
  end
end
