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

    SUFFIX_RE = /[.](rpm)$/
    EPOCH_RE = /([0-9]+):/
    NVRA_RE = /^([^-]+)-([^-]+)-(.+)[.]([^.]+)$/
    NVR_RE = /^([^-]+)-([^-]+)-(.+)$/

    def PackageUtils.parse_nvrea name
      #parses package nvrea and stores it in a hash
      #epoch:name-ve.rs.ion-rel.e.ase.arch.rpm
      package = {}

      suffix_re = SUFFIX_RE
      if name =~ suffix_re
        package[:suffix] = suffix_re.match(name).captures[0]
        name = name.sub(suffix_re, '')
      end

      epoch_re = EPOCH_RE
      if name =~ epoch_re
        package[:epoch] = epoch_re.match(name).captures[0]
        name = name.sub(epoch_re, '')
      end

      nvra_re = NVRA_RE
      if name =~ nvra_re
        parts = nvra_re.match(name).captures
        package[:name] = parts[0]
        package[:version] = parts[1]
        package[:release] = parts[2]
        package[:arch] = parts[3]
      end
      package
    end


    def PackageUtils.parse_nvre name
      #parses package nvre and stores it in a hash
      #epoch:name-ve.rs.ion-rel.e.ase.arch.rpm
      package = {}

      suffix_re = SUFFIX_RE
      if name =~ suffix_re
        package[:suffix] = suffix_re.match(name).captures[0]
        name = name.sub(suffix_re, '')
      end

      epoch_re = EPOCH_RE
      if name =~ epoch_re
        package[:epoch] = epoch_re.match(name).captures[0]
        name = name.sub(epoch_re, '')
      end

      nvra_re = NVR_RE
      if name =~ nvra_re
        parts = nvra_re.match(name).captures
        package[:name] = parts[0]
        package[:version] = parts[1]
        package[:release] = parts[2]
      end
      package
    end


    def PackageUtils.build_nvrea package
      nvrea = package[:name] +'-'+ package[:version] +'-'+ package[:release]
      nvrea = nvrea +'.'+ package[:arch] if not package[:arch].nil?
      nvrea = nvrea +'.'+ package[:suffix] if not package[:suffix].nil?
      nvrea = package[:epoch] +':'+ nvrea if not package[:epoch].nil?
      nvrea
    end


    def PackageUtils.is_nvr name
      name = name.sub(SUFFIX_RE, "")
      name =~ NVR_RE
    end


    def PackageUtils.is_nvre name
      name = name.sub(SUFFIX_RE, "")
      name =~ NVR_RE and name =~ EPOCH_RE
    end


    def PackageUtils.find_latest_packages packages
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

  end
end
