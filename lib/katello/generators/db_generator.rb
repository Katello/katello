require 'rails/generators'

class DbGenerator < Rails::Generators::Base
  source_root File.expand_path('../../../../db', __FILE__)

  def copy_seeds_file
    copy_file 'seeds.rb', 'db/seeds.rb'
  end

  def copy_seeds_dir
    Dir.foreach seeds_dir do |file|
      copy_file "seeds/#{file}", "db/seeds/#{file}"  unless file.match /^\./
    end
  end

  def seeds_dir
    File.expand_path 'seeds', self.class.source_root
  end
end
