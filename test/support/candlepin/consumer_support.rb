require 'katello_test_helper'

module Katello
  module CandlepinConsumerSupport
    @system = nil

    def self.system_id
      @system.id
    end

    class << self
      attr_reader :system
    end

    def self.create_system(name, env, cv)
      @system = System.new
      @system.cp_type = 'system'
      @system.name = name
      @system.description = 'New System'
      @system.environment = env
      @system.content_view = cv
      @system.facts = {}
      @system.arch = 'x86_64'
      @system.sockets = 2
      @system.memory = 256
      @system.virtual_guest = false

      return @system
    end
  end
end
