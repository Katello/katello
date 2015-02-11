#
# Copyright 2014 Red Hat, Inc.
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
  module Util
    module Package
      SUFFIX_RE = /\.(rpm)$/
      ARCH_RE = /\.([^.\-]*)$/
      EPOCH_RE = /([0-9]+):/
      NVRE_RE = /^(?:([0-9]+):)?(.*)-([^-]*)-([^-]*)$/
      SUPPORTED_ARCHS = %w(noarch i386 i686 ppc64 s390x x86_64 ia64)

      #parses package nvrea and stores it in a hash
      #epoch:name-ve.rs.ion-rel.e.ase.arch.rpm
      def self.parse_nvrea(name)
        name, suffix = extract_suffix(name)
        name, arch = extract_arch(name)
        return unless arch

        if nvre = parse_nvre(name)
          nvre.merge(:suffix => suffix, :arch => arch).delete_if { |_k, v| v.nil? }
        end
      end

      #parses package nvre and stores it in a hash
      #epoch:name-ve.rs.ion-rel.e.ase.rpm
      def self.parse_nvre(name)
        name, suffix = extract_suffix(name)

        if match = NVRE_RE.match(name)
          {:suffix => suffix,
           :epoch => match[1],
           :name => match[2],
           :version => match[3],
           :release => match[4]}.delete_if { |_k, v| v.nil? }
        end
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

      def self.extract_arch(name)
        return name.split(ARCH_RE)
      end

      def self.build_nvrea(package, include_zero_epoch = true)
        nvrea = package[:name] + '-' + package[:version] + '-' + package[:release]
        nvrea = nvrea + '.' + package[:arch] unless package[:arch].nil?
        nvrea = nvrea + '.' + package[:suffix] unless package[:suffix].nil?
        unless package[:epoch].nil?
          nvrea = package[:epoch] + ':' + nvrea if package[:epoch].to_i != 0 || include_zero_epoch
        end
        nvrea
      end

      def self.build_nvra(package)
        package = package.with_indifferent_access
        nvra = package[:name] + '-' + package[:version] + '-' + package[:release]
        nvra = nvra + '.' + package[:arch] unless package[:arch].nil?
        nvra = nvra + '.' + package[:suffix] unless package[:suffix].nil?
        nvra
      end

      def self.find_latest_packages(packages)
        latest_pack = nil
        selected_packs = []

        packages.each do |pack|
          next if pack.nil?

          pack = pack.with_indifferent_access
          if (latest_pack.nil?) ||
             (pack[:epoch] > latest_pack[:epoch]) ||
             (pack[:epoch] == latest_pack[:epoch] && pack[:release] > latest_pack[:release]) ||
             (pack[:epoch] == latest_pack[:epoch] && pack[:release] == latest_pack[:release] && pack[:version] > latest_pack[:version])
            latest_pack = pack
            selected_packs = [pack]

          elsif (pack[:epoch] == latest_pack[:epoch] && pack[:release] == latest_pack[:release] && pack[:version] == latest_pack[:version])
            selected_packs << pack
          end
        end

        selected_packs
      end

      def self.divide_packages_by_name(packages)
        pack_map = {}
        packages.each do |p|
          pack_map[p['name']] ||= []
          pack_map[p['name']] << p
        end
        pack_map
      end

      def self.filter_latest_packages_by_name(packages)
        pack_map = divide_packages_by_name packages

        result = []
        pack_map.each_pair do |_name, packs|
          result += find_latest_packages packs
        end
        result
      end

      def self.validate_package_list_format(packages)
        # validate the format of the comma-separated package list provided
        packages = packages.split(/ *, */)

        packages.each do |package_name|
          unless valid_package_name_format(package_name).nil?
            return false
          end
        end

        return packages
      end

      def self.valid_package_name_format(package)
        return (package =~ valid_package_characters)
      end

      def self.valid_package_characters
        /[^abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\-\.\_\+\,]+/
      end

      def self.setup_shared_unique_filter(repoids, search_mode, search_results)
        repo_filter_ids = repoids.collect do |repo|
          {:term => {:repoids => [repo]}}
        end
        case search_mode
        when :shared
          search_results.filter :and, repo_filter_ids
        when :unique
          search_results.filter :or, repo_filter_ids
          search_results.filter :not, :filter => {:and => repo_filter_ids}
        else
          search_results.filter :or, repo_filter_ids
        end
      end

      def self.version_filter(minimum = nil, maximum = nil)
        filters = []
        filters << Util::PackageFilter.new(minimum, Util::PackageFilter::GREATER_THAN).clauses unless minimum.blank?
        filters << Util::PackageFilter.new(maximum, Util::PackageFilter::LESS_THAN).clauses unless maximum.blank?

        filters
      end

      def self.version_eq_filter(version)
        [Util::PackageFilter.new(version, Util::PackageFilter::EQUAL).clauses]
      end

      # Converts a package version to a sortable string
      #
      # See the Fedora docs for what chars are accepted
      # https://fedoraproject.org/wiki/Archive:Tools/RPM/VersionComparison
      #
      # See Pulp's documentation for more info about this algorithm
      # http://pulp-rpm-dev-guide.readthedocs.org/en/latest/sort-index.html
      #
      # @param version [String] a package version (e.g. "3.9")
      # @return [String] a string that can be sorted (e.g. "01-3.01-9")
      def self.sortable_version(version)
        return "" if version.blank?
        pieces = version.scan(/([A-Za-z]+|\d+)/).flatten.map do |chunk|
          chunk =~ /\d+/ ? "#{"%02d" % chunk.length}-#{chunk}" : "$#{chunk}"
        end
        pieces.join(".")
      end
    end
  end
end
