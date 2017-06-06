namespace :gettext do

  desc "Update pot/po files."
  task :find do
    require 'gettext/tools'
    GetText.update_pofiles "katello-disconnected", Dir.glob("bin/katello-disconnected"), "katello-disconnected 1.0.0"
  end

  desc "Create mo-files"
  task :pack do
    puts "To create MO files do this:"
    puts "pushd po; make; popd"
    #require 'gettext/tools'
    #GetText.create_mofiles
  end

end
