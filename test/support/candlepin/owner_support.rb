require 'katello_test_helper'

# rubocop:disable Style/AccessorMethodName
module Katello
  module CandlepinOwnerSupport
    @organization = nil

    def self.organization_id
      @organization.id
    end

    class << self
      attr_reader :organization
    end

    def self.set_owner(org)
      # TODO: this tests should move to actions tests once we
      # have more actions in Dynflow. For now just peform the
      # things that system.set_pulp_consumer did before.
      ForemanTasks.sync_task(::Actions::Candlepin::Owner::Create, name: org.name, label: org.label)
    end

    def set_owner(org)
      self.class.set_owner(org)
    end

    def self.create_organization(name, label)
      @organization = Organization.new
      @organization.name = name
      @organization.label = label
      @organization.description = 'New Organization'
      Organization.stubs(:disable_auto_reindex!).returns

      set_owner(@organization)
      @organization
    rescue => e
      puts e
      @organization
    end

    def self.destroy_organization(organization, cassette = 'support/candlepin/organization')
      VCR.use_cassette(cassette, :match_requests_on => [:path, :params, :method, :body_json]) do
        Resources::Candlepin::Owner.destroy(organization.label)
      end
    rescue RestClient::ResourceNotFound => e
      puts e
    end
  end
end
