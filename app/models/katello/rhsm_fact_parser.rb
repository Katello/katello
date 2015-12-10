module Katello
  class RhsmFactParser < ::FactParser
    def architecture
      name = facts['lscpu.architecture']
      name = "x86_64" if name == "amd64"
      Architecture.where(:name => name).first_or_create unless name.blank?
    end

    def model
      if facts['virt::is_guest'] == "true"
        name = facts['lscpu::hypervisor_vendor']
      else
        name = facts['dmi::system::product_name']
      end
      ::Model.where(:name => name.strip).first_or_create unless name.blank?
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
