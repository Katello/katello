require 'katello_test_helper'

module Katello
  class RhsmFactParserTest < ActiveSupport::TestCase
    def setup
      @facts = {
        'net.interface.eth0.mac_address' => '00:00:00:00:00:12',
        'net.interface.eth0.ipv4_address' => '192.168.0.1',
        'net.interface.eth0.1.mac_address' => '00:00:00:00:00:12',
        'net.interface.eth0.1.ipv4_address' => '192.168.0.2',
        'net.interface.ethnone.mac_address' => 'none',
        'net.interface.eth2.mac_address' => '00:00:00:00:00:13',
        'net.interface.eth3.ipv4_address' => 'Unknown',
        'net.interface.eth3.mac_address' => '00:00:00:00:00:14'
      }
      @parser = RhsmFactParser.new(@facts)
    end

    def test_virtual_interfaces
      assert @parser.interfaces['eth0.1'][:virtual]
      refute @parser.interfaces['eth0'][:virtual]
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

    def test_get_facts_for_interface_with_invalid_ip
      assert_equal @facts['net.interface.eth3.mac_address'], @parser.get_facts_for_interface('eth3')['macaddress']
      assert_empty @parser.get_facts_for_interface('eth3')['ipaddress']
    end

    def test_valid_centos_os
      @facts['distribution.name'] = 'CentOS'
      @facts['distribution.version'] = '7.2'
      @parser = RhsmFactParser.new(@facts)

      assert @parser.operatingsystem.is_a?(::Operatingsystem)
    end

    def test_invalid_centos_os
      @facts['distribution.name'] = 'CentOS'
      @facts['distribution.version'] = '7'
      @parser = RhsmFactParser.new(@facts)

      refute @parser.operatingsystem
    end
  end
end
