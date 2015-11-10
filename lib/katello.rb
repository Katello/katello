require "rails"

require "apipie-rails"

require "rabl"
require "oauth"
require "gettext_i18n_rails"
require "foreigner"
require "foreman-tasks"
require "rest_client"
require "anemone"
require "securerandom"
require "strong_parameters"
require 'foreman_docker'

require "runcible"

require "deface"
require 'jquery-ui-rails'
require 'qpid_messaging'

require "securerandom"

# to make Foreman#in_rake? helper available if Foreman's lib is available
lib_foreman = File.expand_path('lib/foreman', Rails.root)
require lib_foreman if Dir.exist?(lib_foreman)

require File.expand_path("../engines/bastion_katello/lib/bastion_katello", File.dirname(__FILE__))
require "monkeys/anemone"

module Katello
  require "katello/version"
  require "katello/engine"
end
