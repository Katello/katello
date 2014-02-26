require "rails"

require "apipie-rails"

require "rabl"
require "tire"
require "oauth"
require "openid"
require "gettext_i18n_rails"
require "i18n_data"
require "hooks"
require "foreigner"
require "foreman-tasks"
require "rest_client"
require "i18n_data"
require "justified/standard_error"
require "anemone"
require "securerandom"

require "runcible"

require "angular-rails-templates"
require "simple_navigation"
require "haml-rails"
require "compass-rails"
require "ninesixty"
require "ui_alchemy-rails"
require "deface"

require "uuidtools"
require "delayed_job"

require File.expand_path("../engines/bastion/lib/bastion", File.dirname(__FILE__))
require "monkeys/string_to_bool"

# ENGINE: Re-enable after fixing migrations in Katello proper
#require File.expand_path("../engines/fort/lib/fort", File.dirname(__FILE__))

module Katello

  require "katello/app_config"
  require "katello/engine"
  require "katello/load_configuration"
  require "katello/logging"
  require 'katello/middleware/silenced_logger.rb'

end

require File.expand_path("../engines/fort/lib/fort", File.dirname(__FILE__))
