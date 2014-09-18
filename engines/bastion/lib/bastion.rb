require File.expand_path("bastion/engine", File.dirname(__FILE__))
require 'less-rails' if !Rails.env.production? || Foreman.in_rake?

module Bastion
end
