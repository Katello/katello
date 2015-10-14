require 'katello_test_helper'
require 'support/candlepin/owner_support'
require 'support/candlepin/consumer_support'

module Katello
  class GlueCandlepinConsumerTestBase < ActiveSupport::TestCase
    include CandlepinConsumerSupport
    def setup
      User.current = User.find(FIXTURES['users']['admin']['id'])
      VCR.insert_cassette('glue_candlepin_consumer', :match_requests_on => [:path, :params, :method, :body_json])

      @dev      = KTEnvironment.find(FIXTURES['katello_environments']['candlepin_dev']['id'])

      @org      = Organization.find(FIXTURES['taxonomies']['organization2']['id'])
      @org.setup_label_from_name
      @org.stubs(:label_not_changed).returns(true)
      @org.save!

      @dev_cv   = ContentView.find(FIXTURES['katello_content_views']['candlepin_library_dev_cv']['id'])
      @dev_cve  = ContentViewEnvironment.find(FIXTURES['katello_content_view_environments']['candlepin_library_dev_cve']['id'])
      @dev_cve.cp_id = @dev_cv.cp_environment_id @dev

      # Create the environment in candlepin
      CandlepinOwnerSupport.set_owner(@org)

      ForemanTasks.sync_task(::Actions::Katello::ContentView::EnvironmentCreate, @dev_cve)
    end

    def teardown
      super
      unless @dev_cve.nil?
        # To prevent deletion of the fixture object
        @dev_cve.stubs(:destroy).returns(true)
        # ForemanTasks.sync_task(::Actions::Katello::ContentViewEnvironment::Destroy, @dev_cve)
      end
      Resources::Candlepin::Owner.destroy(@org.label) unless @org.nil?
    ensure
      VCR.eject_cassette
    end
  end

  class GlueCandlepinConsumerTestSystem < GlueCandlepinConsumerTestBase
    def setup
      super
      @sys = CandlepinConsumerSupport.create_system('GlueCandlepinConsumerTestSystem_1', @dev, @dev_cv)
      @sys.facts['memory.memtotal'] = '256 MB'
      @sys.facts.delete 'dmi.memory.size'
      @sys.facts['cpu.cpu_socket(s)'] = '2'
      @sys.facts['uname.machine'] = 'x86_64'
    end

    # Socket values
    def test_sockets_candlepin_consumer
      assert_equal 2, @sys.sockets

      @sys.sockets = '1'
      assert_equal 1, @sys.sockets

      @sys.sockets = 1.1
      assert_equal 1, @sys.sockets

      @sys.sockets = 1
      assert_equal 1, @sys.sockets

      @sys.sockets = 'abc'
      assert_equal 0, @sys.sockets
    end

    # Memory values
    def test_memory_candlepin_consumer
      assert_equal((256.0 / 1024.0), @sys.memory)

      @sys.facts['memory.memtotal'] = '2 GB'
      @sys.facts['dmi.memory.size'] = '4 GB'
      assert_equal 2, @sys.memory
      @sys.facts['memory.memtotal'] = nil
      assert_equal 4, @sys.memory

      @sys.memory = 'abc'
      assert_equal 0, @sys.memory
      @sys.facts['memory.memtotal'] = 3_145_728 # 3MB
      assert_equal 3, @sys.memory
    end

    def test_candlepin_system_export
      assert true
      #  assert @dist.export
    end
  end
end
