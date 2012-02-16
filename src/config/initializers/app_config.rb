# Note: Rails 3 loads initializers in alphabetical order therefore configuration objects 
# are not available in all initializers starting with 'a' letter.
require 'ostruct'
require 'yaml'
 
module ApplicationConfiguration


  class Config
    include Singleton

    attr_reader :config_file

    def initialize 
      @config_file = "/etc/katello/katello.yml"
      @config_file = "#{Rails.root}/config/katello.yml" unless File.exists? @config_file

      config = YAML::load_file(@config_file) || {}
      @hash = config['common'] || {}
      @hash.update(config[Rails.env] || {})

      # Hardcode to true to allow 'Headpin' to be added to the locale translation files
      if true
        @hash["app_name"] = 'Katello'
        @hash["katello?"] = true
      else
        @hash["app_name"] = 'Headpin'
        @hash["katello?"] = false
      end

      @ostruct = hashes2ostruct(@hash)

      @ostruct.elastic_index = 'katello' unless @ostruct.respond_to?(:elastic_index)
      @ostruct.elastic_url = 'http://localhost:9200' unless @ostruct.respond_to?(:elastic_url)

      @ostruct.simple_search_tokens = [':', ' and\\b', ' or\\b', ' not\\b'] unless @ostruct.respond_to?(:simple_search_tokens)

      # candlepin and pulp are turned on by default
      @ostruct.use_cp = true unless @ostruct.respond_to?(:use_cp)
      @ostruct.use_pulp = true unless @ostruct.respond_to?(:use_pulp)
      # backticks gets you the equiv of a system() command in Ruby
      version =  `rpm -q katello-common --queryformat '%{VERSION}-%{RELEASE}\n'`
      exit_code = $?
      if exit_code != 0
        hash = `git rev-parse --short HEAD`
        version = "git hash (" + hash.chop + ")"
        exit_code = $?
        if exit_code != 0
          version = "Unknown"
        end
      end
      @ostruct.katello_version = version

      available_locales = ['de', 'en', 'es', 'fr', 'it', 'ja', 'ko', 'pt-BR', 'gu', 'hi', 'mr', 'or', 'ru', 'te', 'pa', 'kn', 'bn', 'ta', 'zh-CN', 'zh-TW']
      @ostruct.available_locales = available_locales unless @ostruct.respond_to?(:available_locales)
    end

    # helper method that converts object to open struct recursively
    def hashes2ostruct(object)
      return case object
      when Hash
        object = object.clone
        object.each do |key, value|
          object[key] = hashes2ostruct(value)
        end
        OpenStruct.new(object)
      when Array
        object = object.clone
        object.map! { |i| hashes2ostruct(i) }
      else
        object
      end
    end

    def to_os
      @ostruct
    end

    def to_hash
      @hash
    end
  end
end

# singleton object itself (to access custom methods)
::AppConfigObject = ApplicationConfiguration::Config.instance

# config as hash structure
::AppConfigHash = ApplicationConfiguration::Config.instance.to_hash

# config as open struct
::AppConfig = ApplicationConfiguration::Config.instance.to_os

# add a default format for date... without this, rendering a datetime included "UTC" as 
# of the string
Time::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M:%S"

unless ::AppConfig.host.present?
   raise (_("You must specify host in %s for %s to work properly") % ["katello.yml", AppConfig.app_name])
end
