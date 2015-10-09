module Katello
  class RhsmFactParser < ::FactParser
    def architecture
      name = facts['lscpu.architecture']
      name = "x86_64" if name == "amd64"
      Architecture.find_or_create_by_name name unless name.blank?
    end

    def model
      if facts['virt::is_guest'] == "true"
        name = facts['lscpu::hypervisor_vendor']
      else
        name = facts['dmi::system::product_name']
      end
      ::Model.find_or_create_by_name(name.strip) unless name.blank?
    end

    #reqiured to be defined, even if they return nil
    def operatingsystem
    end

    def domain
    end

    def environment
    end
  end
end
