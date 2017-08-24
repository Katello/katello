namespace :katello do
  desc "Clean duplicate installed packages"
  task :clean_installed_packages => :environment do
    User.current = User.anonymous_admin

    puts "Populating cache"
    cache = PackageCache.new
    cache.populate

    total = ::Host.count
    count = 1
    ::Host.find_each do |host|
      puts "Host #{count}/#{total} #{host.name}"

      if host.installed_package_ids.any?
        nvras = host.installed_packages.pluck(:nvra)
        ids = nvras.map { |nvra| cache.fetch(nvra) }
        existing_ids = host.installed_package_ids.to_a
        unless existing_ids.sort == ids.sort
          host.sync_package_associations(ids)
        end
      end
      count += 1
    end

    existing = Katello::HostInstalledPackage.select(:installed_package_id).uniq.pluck(:installed_package_id)

    batch = 20_000
    until Katello::InstalledPackage.where('id not in (?)', existing).limit(1).count == 0
      deleted = Katello::InstalledPackage.where('id not in (?)', existing).where("id < #{batch}").delete_all
      sleep(3) if deleted > 0
      puts "Batch of installed packages deleted, #{Katello::InstalledPackage.count} remaining in total"
      batch += 20_000
    end

    Setting[:bulk_query_installed_packages] = true
  end

  class PackageCache
    def initialize
      @cache = {}
    end

    def populate
      Katello::InstalledPackage.select("nvra, MIN(id) as id").group("nvra").each do |pkg|
        @cache[pkg.nvra] = pkg.id
      end
    end

    def fetch(nvra)
      @cache[nvra] ||= Katello::InstalledPackage.where(:nvra => nvra).first.id
    end
  end
end
