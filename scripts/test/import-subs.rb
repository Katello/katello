User.current = User.first
provider = Provider.where(:name=>"Red Hat").first
imported = provider.import_manifest("../cli/test-system/fake-manifest.zip")
puts "Imported? #{imported}"
