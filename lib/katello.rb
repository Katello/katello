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
require 'foreman_docker'

require "runcible"

require "haml-rails"
require "deface"
require 'jquery-ui-rails'
require 'qpid_messaging'

require "securerandom"

# to make Foreman#in_rake? helper available if Foreman's lib is available
lib_foreman = File.expand_path('lib/foreman', Rails.root)
require lib_foreman if Dir.exist?(lib_foreman)

require File.expand_path("../engines/bastion_katello/lib/bastion_katello", File.dirname(__FILE__))
require "monkeys/string_to_bool"
require "monkeys/anemone"

module Katello
  require "katello/version"
  require "katello/app_config"
  require "katello/engine"
  require "katello/load_configuration"
  require "katello/logging"
  require 'katello/middleware/silenced_logger.rb'
end
