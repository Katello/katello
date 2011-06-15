require 'compass'
require 'compass/app_integration/rails'

# Just add this line to stop sass from compiling in production mode
# Sass::Plugin.options[:never_update] = true

Compass::AppIntegration::Rails.initialize!
