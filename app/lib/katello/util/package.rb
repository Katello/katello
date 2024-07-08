module Katello
  module Util
    module Package
      SUFFIX_RE = /\.(rpm)$/.freeze
      ARCH_RE = /\.([^.\-]*)$/.freeze
      NVRE_RE = /^(.*)-(?:([0-9]+):)?([^-]*)-([^-]*)$/.freeze
      EVR_RE = /^(?:([0-9]+):)?(.*?)(?:-([^-]*))?$/.freeze
      SUPPORTED_ARCHS = %w(noarch i386 i686 ppc64 s390x x86_64 ia64).freeze

      # is able to take both nvre and nvrea and parse it correctly
      def self.parse_nvrea_nvre(name)
        package = self.parse_nvrea(name)
        if package && SUPPORTED_ARCHS.include?(package[:arch])
          return package
        else
          return self.parse_nvre(name)
        end
      end

      #parses package nvrea and stores it in a hash
      #name-epoch:ve.rs.ion-rel.e.ase.arch.rpm
      def self.parse_nvrea(name)
        name, suffix = extract_suffix(name)
        name, arch = extract_arch(name)

        if (nvre = parse_nvre(name))
          nvre.merge(:suffix => suffix, :arch => arch).delete_if { |_k, v| v.nil? }
        end
      end

      #parses package nvre and stores it in a hash
      #name-epoch:ve.rs.ion-rel.e.ase.rpm
      def self.parse_nvre(name)
        name, suffix = extract_suffix(name)

        if (match = NVRE_RE.match(name))
          {:suffix => suffix,
           :name => match[1],
           :epoch => match[2],
           :version => match[3],
           :release => match[4]}.delete_if { |_k, v| v.nil? }
        end
      end

      def self.parse_evr(evr)
        if (match = EVR_RE.match(evr))
          {:epoch => match[1],
           :version => match[2],
           :release => match[3]}.delete_if { |_k, v| v.nil? }
        end
      end

      def self.extract_suffix(name)
        return name.split(SUFFIX_RE)
      end

      def self.extract_arch(name)
        return name.split(ARCH_RE)
      end

      def self.format_requires(requires)
        flags = {'GT' => '>', 'LT' => '<', 'EQ' => '=', 'GE' => '>=', 'LE' => '<='}
        if requires['flags']
          "#{requires['name']} #{flags[requires['flags']]} #{build_vrea(requires, false)}"
        else
          build_nvrea(requires, false)
        end
      end

      def self.build_nvrea(package, include_zero_epoch = true)
        [package[:name], build_vrea(package, include_zero_epoch)].compact.reject(&:empty?).join('-')
      end

      def self.build_vrea(package, include_zero_epoch = true)
        vrea =  [package[:version], package[:release]].compact.join('-')
        vrea = vrea + '.' + package[:arch] unless package[:arch].nil?
        vrea = vrea + '.' + package[:suffix] unless package[:suffix].nil?
        if !package[:epoch].nil? && (package[:epoch].to_i != 0 || include_zero_epoch)
          vrea = package[:epoch] + ':' + vrea
        end
        vrea
      end

      def self.build_nvra(package)
        package = package.with_indifferent_access
        nvra = "#{package[:name]}-#{package[:version]}-#{package[:release]}"
        nvra = "#{nvra}.#{package[:arch]}" unless package[:arch].nil?
        nvra = "#{nvra}.#{package[:suffix]}" unless package[:suffix].nil?
        nvra
      end

      def self.find_latest_packages(packages)
        latest_pack = nil
        selected_packs = []

        packages.each do |pack|
          next if pack.nil?

          pack = pack.with_indifferent_access
          if latest_pack.nil? ||
             (pack[:epoch].to_i > latest_pack[:epoch].to_i) ||
             (pack[:epoch].to_i == latest_pack[:epoch].to_i &&
              pack[:version_sortable] > latest_pack[:version_sortable]) ||
             (pack[:epoch].to_i == latest_pack[:epoch].to_i &&
              pack[:version_sortable] == latest_pack[:version_sortable] &&
              pack[:release_sortable] > latest_pack[:release_sortable])
            latest_pack = pack
            selected_packs = [pack]

          elsif (pack[:epoch].to_i == latest_pack[:epoch].to_i &&
                 pack[:version_sortable] == latest_pack[:version_sortable] &&
                 pack[:release_sortable] == latest_pack[:release_sortable])
            selected_packs << pack
          end
        end

        selected_packs
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

      def self.parse_dependencies(dependencies)
        # dependencies is either 'requires' or 'provides' metadata attribute of rpm package in pulp
        results = []
        flags = {'GT' => '>', 'LT' => '<', 'EQ' => '=', 'GE' => '>=', 'LE' => '<='}

        dependencies&.each do |dependency|
          dependencies_str = ""
          if dependency.count < 3
            dependencies_str = dependency.first
            results << dependencies_str
          else
            dependency[1] = flags[dependency[1]]
            dependency[0...2].each { |dependency_piece| dependencies_str += "#{dependency_piece} " }
            dependencies_str += "#{dependency[2]}:" unless dependency[2] == "0" # epoch
            dependencies_str += "#{dependency[3]}-" # version
            dependency[4...-1].each { |dependency_piece| dependencies_str += "#{dependency_piece}." }
            results << dependencies_str[0...-1]
          end
        end
        results.uniq
      end
    end
  end
end
