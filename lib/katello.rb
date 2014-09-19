require "rails"

require "apipie-rails"

require "rabl"
require "tire"
require "oauth"
require "gettext_i18n_rails"
require "i18n_data"
require "hooks"
require "foreigner"
require "foreman-tasks"
require "rest_client"
require "justified/standard_error"
require "anemone"
require "securerandom"

require "runcible"

require "angular-rails-templates"
require "haml-rails"
require "compass-rails"
require "ninesixty"
require "ui_alchemy-rails"
require "deface"
require 'jquery-ui-rails'

require "uuidtools"

# to make Foreman#in_rake? helper available
require File.expand_path('lib/foreman', Rails.root)
require File.expand_path("../engines/bastion/lib/bastion", File.dirname(__FILE__))
require "monkeys/string_to_bool"
require "monkeys/anemone"

module Katello

  require "katello/app_config"
  require "katello/engine"
  require "katello/load_configuration"
  require "katello/logging"
  require 'katello/middleware/silenced_logger.rb'

end
