require 'katello_test_helper'

module Katello
  class RhsmFactParserTest < ActiveSupport::TestCase
    def setup
      @facts = {
        'net.interface.eth0.mac_address' => '00:00:00:00:00:12',
        'net.interface.eth0.ipv4_address' => '192.168.0.1',
        'net.interface.ethnone.mac_address' => 'none',
        'net.interface.eth2.mac_address' => '00:00:00:00:00:13'
      }
      @parser = RhsmFactParser.new(@facts)
    end

    def test_get_interfaces
      interfaces = @parser.get_interfaces
      assert_includes interfaces, 'eth0'
      refute_includes interfaces, 'ethnone'
      assert_includes interfaces, 'eth2'
    end

    def test_get_facts_for_interface_with_ip
      expected_eth0 = {
        'link' => true,
        'macaddress' => @facts['net.interface.eth0.mac_address'],
        'ipaddress' => @facts['net.interface.eth0.ipv4_address']
      }
      assert_equal expected_eth0, @parser.get_facts_for_interface('eth0')
    end

    def test_get_facts_for_interface_without_ip
      expected_eth1 = {
        'link' => true,
        'macaddress' => @facts['net.interface.eth1.mac_address'],
        'ipaddress' => nil
      }
      assert_equal expected_eth1, @parser.get_facts_for_interface('eth1')
    end
  end
end
