#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  module PackageUtils

    SUFFIX_RE = /\.(rpm)$/
    EPOCH_RE = /([0-9]+):/
    NVREA_RE = /^(?:([0-9]+):)?([^.]+)-([^-]+)-(.+)[.]([^.]+)?$/
    SUPPORTED_ARCHS = %w[noarch i386 i686 ppc64 s390x x86_64 ia64]

    #parses package nvrea and stores it in a hash
    #epoch:name-ve.rs.ion-rel.e.ase.arch.rpm
    def self.parse_nvrea(name)
      name, suffix = extract_suffix(name)
      package = {:suffix => suffix}

      if match = NVREA_RE.match(name)
        package.merge!(:epoch => match[1],
         :name => match[2],
         :version => match[3],
         :release => match[4],
         :arch => match[5])
        return package.delete_if{|k,v| v.nil?}
      else
        return
      end

    end

    #parses package nvre and stores it in a hash
    #epoch:name-ve.rs.ion-rel.e.ase.arch.rpm
    def self.parse_nvre(name)
      package = parse_nvrea(name)
      return unless package

      if package[:arch]
        package[:release] << ".#{package[:arch]}"
        package.delete(:arch)
      end

      package
    end

    # is able to take both nvre and nvrea and parse it correctly
    def self.parse_nvrea_nvre(name)
      package = self.parse_nvrea(name)
      if package && SUPPORTED_ARCHS.include?(package[:arch])
        return package
      else
        return self.parse_nvre(name)
      end

    end

    def self.extract_suffix(name)
      return name.split(SUFFIX_RE)
    end

    def self.build_nvrea(package, include_zero_epoch=true)
      nvrea = package[:name] +'-'+ package[:version] +'-'+ package[:release]
      nvrea = nvrea +'.'+ package[:arch] if not package[:arch].nil?
      nvrea = nvrea +'.'+ package[:suffix] if not package[:suffix].nil?
      if not package[:epoch].nil?
        nvrea = package[:epoch] +':'+ nvrea if package[:epoch].to_i != 0 || include_zero_epoch
      end
      nvrea
    end

    def self.find_latest_packages(packages)
      latest_pack = nil
      selected_packs = []

      packages.each do |pack|

        next if pack.nil?

        pack = pack.with_indifferent_access
        if (latest_pack.nil?) or
           (pack[:epoch] > latest_pack[:epoch]) or
           (pack[:epoch] == latest_pack[:epoch] and pack[:release] > latest_pack[:release]) or
           (pack[:epoch] == latest_pack[:epoch] and pack[:release] == latest_pack[:release] and pack[:version] > latest_pack[:version])
          latest_pack = pack
          selected_packs = [pack]

        elsif (pack[:epoch] == latest_pack[:epoch] and pack[:release] == latest_pack[:release] and pack[:version] == latest_pack[:version])
          selected_packs << pack
        end
      end

      selected_packs
    end

    def self.divide_packages_by_name packages
      pack_map = {}
      packages.each do |p|
          pack_map[p['name']] ||= []
          pack_map[p['name']] << p
      end
      pack_map
    end

    def self.filter_latest_packages_by_name packages
      pack_map = divide_packages_by_name packages

      result = []
      pack_map.each_pair do |name, packs|
        result += find_latest_packages packs
      end
      result
    end


  end
end
