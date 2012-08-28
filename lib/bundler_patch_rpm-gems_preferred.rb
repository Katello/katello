module Bundler

  unless defined? PREFER_RPM_GEMS
    PREFER_RPM_GEMS = true

    bundler_version = Bundler::VERSION.split('.').map(&:to_i)

    unless bundler_version[0..1] == [1, 0]
      Bundler.ui.info "Only bundler version 1.0.x is supported\n#{__FILE__}"
    else
      Bundler.ui.info 'Preferring rpm-gems over gems.'

      class RpmGemTest
        attr_reader :gem_spec

        def self.rpm_command_available?
          if @rpm_command_available.nil?
            `rpm --version 2>&1`
            @rpm_command_available = $?.exitstatus == 0
          else
            @rpm_command_available
          end
        end

        def initialize(gem_spec)
          @gem_spec = gem_spec
        end

        def gem_name
          gem_spec.name
        end

        def rpm_name
          "rubygem-#{gem_name}"
        end

        def rpm_full_name
          return nil if !self.class.rpm_command_available? || @rpm_full_name == false

          name = `rpm -q #{rpm_name} 2>&1`
          if $?.exitstatus == 0
            return @rpm_full_name = name
          else
            @rpm_full_name = false
            return nil
          end
        end

        def rpm_installed?
          !!rpm_full_name
        end

        def rpm_gem?
          rpm_installed? and potential_spec_files.include?(gem_spec.loaded_from)
        end

        private

        def potential_spec_files
          raise "rpm-gem #{rpm_name} is not installed" unless rpm_installed?
          paths = `rpm -ql #{rpm_name} | grep --color=never .gemspec 2>&1`.split
          raise "failed to find .gemspec file for rpm-gem '#{rpm_name}'" unless $?.exitstatus == 0
          return paths
        end

      end

      class RpmGemCacheImpl
        def initialize
          @cache = { }
        end

        def rpm_gem?(gem_spec)
          if @cache.has_key?(name = gem_spec.name)
            @cache[name]
          else
            @cache[name] = RpmGemTest.new(gem_spec).rpm_gem?
          end
        end
      end

      RpmGemCache = RpmGemCacheImpl.new

      class Resolver
        def search_with_local_gems_preferred(dep)
          matching_versions = search_without_local_gems_preferred dep

          rpm_gems = matching_versions.select { |matching_version| RpmGemCache.rpm_gem? matching_version[0] }
          others   = matching_versions - rpm_gems
          return others + rpm_gems
        end

        alias_method :search_without_local_gems_preferred, :search
        alias_method :search, :search_with_local_gems_preferred
      end
    end
  end
end
