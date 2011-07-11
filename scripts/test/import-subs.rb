User.current = User.first
provider = Provider.where(:name=>"red hat").first
imported = provider.import_manifest("../scripts/test/export-manifest.zip")
puts "Imported? #{imported}"
