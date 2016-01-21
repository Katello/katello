module Katello
  class RhsmFactParser < ::FactParser
    def architecture
      name = facts['lscpu.architecture']
      name = "x86_64" if name == "amd64"
      Architecture.where(:name => name).first_or_create unless name.blank?
    end

    def model
      if facts['virt::is_guest'] == "true"
        name = facts['lscpu.hypervisor_vendor']
      else
        name = facts['dmi.system.product_name']
      end
      ::Model.where(:name => name.strip).first_or_create unless name.blank?
    end

    def support_interfaces_parsing?
      true
    end

    def get_facts_for_interface(interface)
      {
        'link' => true,
        'macaddress' => facts["net.interface.#{interface}.mac_address"],
        'ipaddress' => facts["net.interface.#{interface}.ipv4_address"]
      }
    end

    # rubocop:disable Style/AccessorMethodName:
    def get_interfaces
      mac_keys = facts.keys.select { |f| f =~ /net\.interface\..*\.mac_address/ }
      names = mac_keys.map do |key|
        key.sub('net.interface.', '').sub('.mac_address', '') if facts[key] != 'none'
      end
      names.compact
    end

    #reqiured to be defined, even if they return nil
    def operatingsystem
    end

    def domain
    end

    def environment
    end

    def ipmi_interface
    end
  end
end
