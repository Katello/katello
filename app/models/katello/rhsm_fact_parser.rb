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

    def operatingsystem
      name = facts['distribution.name']
      version = facts['distribution.version']
      return nil if name.nil? || version.nil?

      os_name = ::Katello::Candlepin::Consumer.distribution_to_puppet_os(name)
      major, minor = version.split('.')
      if os_name && !invalid_centos_os?(os_name, minor)
        os_attributes = {:major => major, :minor => minor || '', :name => os_name}
        ::Operatingsystem.find_by(os_attributes) || ::Operatingsystem.create!(os_attributes)
      end
    end

    def invalid_centos_os?(name, minor_version)
      name == 'CentOS' && minor_version.blank?
    end

    #required to be defined, even if they return nil
    def domain
    end

    def environment
    end

    def ipmi_interface
    end
  end
end
