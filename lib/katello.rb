require "rails"

require "apipie-rails"
require "activerecord-import"
require "rabl"
require "oauth"
require "gettext_i18n_rails"
require "foreman-tasks"
require "foreman_remote_execution"
require "rest_client"
require "securerandom"

require "deface"

# to make Foreman#in_rake? helper available if Foreman's lib is available
lib_foreman = File.expand_path('lib/foreman', Rails.root)
require lib_foreman if Dir.exist?(lib_foreman)

require File.expand_path("../engines/bastion/lib/bastion", File.dirname(__FILE__))
require File.expand_path("../engines/bastion_katello/lib/bastion_katello", File.dirname(__FILE__))

module Katello
  require "katello/version"
  require "katello/engine"
end
