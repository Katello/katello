path = File.expand_path('../lib', File.dirname(__FILE__))
$LOAD_PATH << path unless $LOAD_PATH.include? path

require 'katello/load_configuration'
require 'ninesixty'

if Compass.version[:minor] < 12
  # in 0.12, rails integration was broken out into compass-rails
  project_type = :rails
end

# Set this to the root of your project when deployed:
http_path = ::Katello.early_config.url_prefix
css_dir = "public/stylesheets/compiled"
sass_dir = "app/stylesheets"
images_dir = "public/images"
relative_assets = true
http_fonts_dir = http_path + "/fonts/"
