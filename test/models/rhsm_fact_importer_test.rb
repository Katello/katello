require 'katello_test_helper'

module Katello
  class RhsmFactImporterTest < ActiveSupport::TestCase
    def setup
      @facts = {
        'net.interface.eth0.mac_address' => '00:00:00:00:00:12',
        'net.interface.eth0.ipv4_address' => '192.168.0.1',
        'net.interface.eth1.mac_address' => '00:00:00:00:00:13',
        'distribution.name' => 'Red Hat', 'distribution.version' => '3.2'
      }
      @host =  ::Host::Managed.new(:name => "here.be.dragons", :managed => false)
    end

    def test_import_facts
      assert_nil @host.operatingsystem
      Host::SubscriptionFacet.update_facts(@host, @facts)
      assert @host.save
      assert_equal 2, @host.interfaces.length
      assert @host.interfaces.find_by(:identifier => 'eth0').primary?

      fact1 = @facts.keys[0]
      assert_equal @facts[fact1], @host.facts[fact1.gsub('.', '::')]
      refute_nil @host.operatingsystem
    end
  end
end
