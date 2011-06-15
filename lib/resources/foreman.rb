#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'rubygems'
require 'rest_client'
require 'cgi'
require 'http_resource'

module Foreman

  module REST
    def get
      JSON.parse(super(path(), :accept => :json).body)
    end
  end

  class ForemanResource
    attr_reader :url, :username, :password

    def initialize options = {}
      @url = AppConfig.foreman.url || raise("no foreman url was given")
      @username = AppConfig.foreman.username || raise("no foreman username was given")
      @password = AppConfig.foreman.password || raise("no foreman password was given")

      @resource = RestClient::Resource.new url, username, password
    end

    def get(path, headers={})
      @resource[path].get headers
    end

    def post(path, params = {})
      @resource[path].post headers
    end

    def opts
      {:url => url, :username => username, :password => password}
    end

    # Encode url element if its not nil. This helper method is used mainly in resource path methods.
    #
    # @param [String] element to encode
    # @return [String] encoded element or nil
    def url_encode(element)
      CGI::escape element unless element.nil?
    end
  end

  class Host < ForemanResource
    include Foreman::REST
    attr_reader :uuid

    def initialize options = {}
      super options
      # if no uuid is assign, we return all uuid's
      @uuid = options[:uuid]
    end

    def list
      get.collect do |uuid|
        Host.new(opts.merge({:uuid => uuid}))
      end
    end

    def path
      "/hosts"
    end

  end

  class Facts < ForemanResource
    include Foreman::REST
    attr_reader :uuid, :values

    def initialize options = {}
      super options
      @uuid = options[:uuid]
      raise "no uuid was given" unless @uuid
      @values = get[uuid]
    end

    def [](key)
      @values[key]
    end

    def path
      "/hosts/#{uuid}/facts"
    end

  end

  class Environment < ForemanResource
    include Foreman::REST
    attr_reader :name

    def initialize options = {}
      super options
      @name = options[:name]
    end

    def list
      get.collect do |json|
        json["environment"]["name"]
      end
    end

    def nodes
      return nil unless name
      get["environment"]["hosts"].collect do |json|
        Host.new(opts.merge({:uuid => json["name"]}))
      end
    end

    def path
      "/environments/#{url_encode name}"
    end
  end

  class Puppetclass < ForemanResource
    include Foreman::REST
    attr_reader :name, :id, :module

    def initialize(options = {})
      super(options)
      @name = options[:name]
      @module = options[:module]
      @id = options[:id]
    end

    # returns a hash of modules and their respective classes
    def list
      hash = {}
      get.each_pair do |pmodule, pclasses|
        hash[pmodule] = pclasses.collect do |klass|
          {:module => pmodule, :name => klass["puppetclass"]["name"], :id => klass["puppetclass"]["id"]}
        end
      end
      return hash
    end

    def path
      "/puppetclasses/#{url_encode name}"
    end
  end

end
