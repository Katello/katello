require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  class GluePulpPuppetModuleTest < ActiveSupport::TestCase
    def setup
      set_user
      configure_runcible

      VCR.insert_cassette('glue_pulp_puppet_module')

      @repository = Repository.find(katello_repositories(:p_forge))
      RepositorySupport.create_and_sync_repo(@repository)

      @names = ["cron", "httpd", "pureftpd", "samba"]
    end

    def teardown
      RepositorySupport.destroy_repo
      VCR.eject_cassette
    end

    def test_generate_unit_data
      path = File.join(Katello::Engine.root, "test/fixtures/puppet/puppetlabs-ntp-2.0.1.tar.gz")
      unit_key, unit_metadata = PuppetModule.generate_unit_data(path)

      assert_equal "puppetlabs", unit_key["author"]
      assert_equal "ntp", unit_key[:name]

      assert_equal [], unit_metadata[:tag_list]
      assert_nil unit_metadata[:name]
      assert_nil unit_metadata[:author]
    end
  end
end
