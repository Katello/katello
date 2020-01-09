module Katello
  class RhsmFactParser < ::FactParser
    def architecture
      name = facts['lscpu.architecture'] || facts['uname.machine']
      name = "x86_64" if name == "amd64"
      name = "i386" if name == "i686"
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
        'macaddress' => get_rhsm_mac(interface),
        'ipaddress' => get_rhsm_ip(interface)
      }
    end

    def interfaces
      virtual_interface_regexp = /\A([^.]*?)\.(\d+)\z/
      super.tap do |interfaces|
        interfaces.each do |name, attributes|
          attributes[:virtual] = true if name =~ virtual_interface_regexp
        end
      end
    end

    # rubocop:disable Naming/AccessorMethodName:
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
      unless facts['ignore_os']
        os_attributes = {:major => major, :minor => minor || '', :name => os_name}

        release_name = os_release_name(os_name)
        if release_name
          os_attributes[:release_name] = release_name
        end

        ::Operatingsystem.find_by(os_attributes) || ::Operatingsystem.create!(os_attributes)
      end
    end

    def os_release_name(os_name)
      if os_name&.match(::Operatingsystem::FAMILIES['Debian'])
        facts['distribution.id']&.split&.first&.downcase
      end
    end

    #required to be defined, even if they return nil
    def domain
    end

    def environment
    end

    def ipmi_interface
    end

    def boot_timestamp
      facts['proc_stat.btime']&.to_i
    end

    def virtual
      facts['virt.is_guest']
    end

    def ram
      facts['memory.memtotal'].to_i / 1024 if facts['memory.memtotal']
    end

    def sockets
      facts['cpu.cpu_socket(s)']
    end

    def cores
      facts['cpu.core(s)_per_socket']
    end

    private

    def get_rhsm_ip(interface)
      ip = facts["net.interface.#{interface}.ipv4_address"]
      Net::Validations.validate_ip(ip) ? ip : nil
    end

    def get_rhsm_mac(interface)
      # if slave then permanent_mac_address contains the physical mac
      facts["net.interface.#{interface}.permanent_mac_address"] || facts["net.interface.#{interface}.mac_address"]
    end
  end
end
