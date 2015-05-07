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

    @distributor = nil

    def self.distributor_id
      @distributor.id
    end

    class << self
      attr_reader :distributor
    end

    def self.create_distributor(name, env, cv)
      @distributor = Distributor.new
      @distributor.cp_type = 'candlepin'
      @distributor.name = name
      @distributor.description = 'New Distributor'
      @distributor.environment = env
      @distributor.content_view = cv
      @distributor.facts = {"distributor_version" => Distributor.latest_version}

      return @distributor
    end
  end
end
