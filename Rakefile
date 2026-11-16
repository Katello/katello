# Packaging tasks, runnable from a bare checkout: they need only rake, make
# and msgfmt, not Rails or Foreman. Foreman does not load this file.
#
# pkg:generate_source is the entry point the release pipelines call, matching
# foreman, smart-proxy, foreman-installer and hammer-cli. It leaves its
# artifact in pkg/, and depends on pkg:compile_locale so that a gem can never
# be built without its gettext catalogs.
namespace :pkg do
  desc 'Compile the gettext catalogs (locale/*/LC_MESSAGES/katello.mo)'
  task :compile_locale do
    cd __dir__ do
      sh 'make', '-C', 'locale', 'all-mo'

      # make exits 0 when it has nothing to do, so check the result ourselves
      pos = Dir['locale/*/katello.po']
      abort 'No locale/*/katello.po found, refusing to build without catalogs' if pos.empty?
      missing = pos.reject { |po| File.size?(File.join(File.dirname(po), 'LC_MESSAGES', 'katello.mo')) }
      abort "Missing compiled catalogs for: #{missing.join(', ')}" unless missing.empty?
      puts "Compiled #{pos.size} gettext catalogs"
    end
  end

  desc 'Generate package source into pkg/, including the compiled catalogs'
  task :generate_source => :compile_locale do
    cd __dir__ do
      require_relative 'lib/katello/version'
      mkdir_p 'pkg'
      gem_file = File.join('pkg', "katello-#{Katello::VERSION}.gem")
      rm_f gem_file
      sh 'gem', 'build', 'katello.gemspec', '--output', gem_file
      puts gem_file
    end
  end
end
