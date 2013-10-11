require "apipie-rails"

require "rabl"
require "tire"
require "oauth"
require "openid"
require "gettext_i18n_rails"
require "i18n_data"
require "ruport/acts_as_reportable"
require "hooks"
require "logger"
require "foreigner"
require "dynflow"
require "rest_client"
require "i18n_data"
require "justified/standard_error"

require "runcible"

require "simple_navigation"
require "haml-rails"
require "compass-rails"
require "ninesixty"
require "ui_alchemy-rails"

require "uuidtools"
require "delayed_job"

require File.expand_path("../engines/bastion/lib/bastion", File.dirname(__FILE__))

# ENGINE: Re-enable after fixing migrations in Katello proper
#require File.expand_path("../engines/fort/lib/fort", File.dirname(__FILE__))

# Namespace properly to katello/app_config
require "app_config"

module Katello

  require "katello/engine"
  require "katello/load_configuration"
  require "katello/logging"

end
