desc 'Updates stylesheets if necessary from their Sass templates.'
namespace :sass do
  task :update => :environment do
    Sass::Plugin.update_stylesheets
  end
end
