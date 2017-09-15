namespace :katello do
  desc "Clean duplicate installed packages"
  task :clean_installed_packages => :environment do
    User.current = User.anonymous_admin

    puts "Populating cache"
    cache = PackageCache.new
    cache.populate

    puts "Cleaning katello_host_installed_packages table.."
    cleaning_start = Time.now
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

    cleaning_total = sprintf('%.2f', Time.now - cleaning_start)
    puts "katello_host_installed_packages table has been cleaned, total time was #{cleaning_total} seconds."
    puts "Removing records from katello_installed_packages that are no longer referenced..."
    cleaning_start = Time.now

    existing = Katello::HostInstalledPackage.select(:installed_package_id).uniq.pluck(:installed_package_id)

    interrupted_run = false
    batch = 20_000
    until Katello::InstalledPackage.where('id not in (?)', existing).limit(1).count == 0
      begin
        deleted = Katello::InstalledPackage.where('id not in (?)', existing).where("id < #{batch}").delete_all
        sleep(3) if deleted > 0
        puts "Inspected #{batch} records in katello_host_installed_packages to remove unreferenced entries in katello_installed_packages.."
      rescue ActiveRecord::InvalidForeignKey
        puts "Some records in this batch were unable to be removed. This is usually due to system registrations or updates that occurred after the script started."
        puts "Cleanup will continue, but please re-run this script later (possibly during a more quiet time for the system) to fully clean set of packages."
        interrupted_run = true
      end
      batch += 20_000
    end
    cleaning_total = sprintf('%.2f', Time.now - cleaning_start)
    puts "katello_installed_packages table has been cleaned to remove unreferenced entries, total time was #{cleaning_total} seconds."

    if interrupted_run
      puts "Script is complete, but some records were not able to be removed. This may affect system performance depending on how many records remain."
      puts "To clean all records, run script again during a period with fewer Satellite activities, or shut down httpd and re-run."
    else
      puts "Script is complete, setting installed package search to updated method. To disable this, set 'bulk query installed packages' to 'false' in Katello settings."
      Setting[:bulk_query_installed_packages] = true
    end
    puts "Done!"
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
