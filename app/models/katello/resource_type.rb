#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  class VerbNotFound < StandardError
    attr_reader :verb
    attr_reader  :possible_verbs
    attr_reader :resource_type

    def initialize resource_type, verb, possible_verbs
      @verb = verb
      @possible_verbs = possible_verbs
      @resource_type = resource_type
    end

    def message
      params = {:verb => @verb, :possible_verbs => @possible_verbs.join(', '), :resource_type => @resource_type}
      N_("Invalid verb '%{verb}'. Verbs for resource type '%{resource_type}' can be one of %{possible_verbs}") % params
    end
  end
end

module Katello
  class ResourceTypeNotFound < StandardError
    attr_reader :resource_type
    attr_reader  :possible_types

    def initialize resource_type, possible_types
      @resource_type = resource_type
      @possible_types = possible_types
    end

    def message
      params = {:possible_types => @possible_types.join(', '), :resource_type => @resource_type}
      N_("Invalid resource type '%{resource_type}'. Resource Types can be one of '%{possible_types}'") % params
    end
  end
end

module Katello
  class DefaultModel
    class << self
      def list_tags(global=false); []; end
      def tags_for(global=false); []; end
      def tags(global=false); []; end
      def no_tag_verbs(global=false); []; end
      def list_verbs(global=false); {}; end
      def tags_for(global=false); []; end
    end
  end
end

module Katello
  class ResourceType < ActiveRecord::Base
    belongs_to :permission
    validates :name, :length => { :maximum => 255 }

    def display_name
      ResourceType::TYPES[name][:name]
    end

    def global?
      r = ResourceType::TYPES[name]
      return r[:global] if r && r[:global]
      false
    end

    def model
      ResourceType.model_for(name)
    end

    def self.global_types
      TYPES.collect{|key, value| key if value[:global]}.compact
    end

    def self.model_for resource_type
      check_type resource_type
      TYPES[resource_type][:model]
    end

    def self.check resource_type, verbs = []
      check_type resource_type

      model = model_for resource_type


      possible_verbs = (model.list_verbs(true).keys + model.list_verbs(false).keys).uniq
      verbs = [] if verbs.nil?
      verbs = [verbs] unless Array === verbs
      verbs.each { |verb|
        raise VerbNotFound.new(resource_type,verb, possible_verbs) unless possible_verbs.include? verb.to_s
      }

    end

    def self.check_type resource_type
      raise ResourceTypeNotFound.new(resource_type, TYPES.keys) unless TYPES.has_key? resource_type
    end

    if Katello.config.katello?
      TYPES = {
          :organizations => {:model => ::Organization, :name => _("Organizations"), :global=>false},
          :environments => {:model => Katello::KTEnvironment, :name => _("Environments"), :global=>false},
          :activation_keys => { :model => Katello::ActivationKey, :name => _("Activation Keys"), :global=>false},
          :system_groups => {:model => Katello::SystemGroup, :name=>_("System Groups"), :global=>false},
          :providers => { :model => Katello::Provider, :name => _("Providers"), :global=>false},
          :users => { :model => ::User, :name => _("Users"), :global=>true},
          :roles => { :model => Katello::Role, :name => _("Roles"), :global=>true},
          :content_view_definitions => { :model => Katello::ContentViewDefinition,
            :name => _("Content View Definitions"), :global => false},
          :content_views => { :model => Katello::ContentView, :name => _("Content View"), :global => false},
          :all => { :model => Katello::DefaultModel, :name => _("All"), :global => false}
       }.with_indifferent_access
    else
      TYPES = {
          :organizations => {:model => Organization, :name => _("Organizations"), :global=>false},
          :environments => {:model => KTEnvironment, :name => _("Environments"), :global=>false},
          :activation_keys => { :model => ActivationKey, :name => _("Activation Keys"), :global=>false},
          :system_groups => {:model => SystemGroup, :name=>_("System Groups"), :global=>false},
          :providers => { :model => Provider, :name => _("Providers"), :global=>false},
          :users => { :model => User, :name => _("Users"), :global=>true},
          :roles => { :model => Role, :name => _("Roles"), :global=>true},
          :all => { :model => DefaultModel, :name => _("All"), :global => false}
      }.with_indifferent_access
    end

  end
end
