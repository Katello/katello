# to make Foreman#in_rake? helper available if Foreman's lib is available
require 'rails'
require 'angular-rails-templates'

require File.expand_path('bastion/engine', File.dirname(__FILE__))

#rubocop:disable Style/ClassVars
module Bastion
  @@plugins = {}

  def self.plugins
    @@plugins
  end

  def self.register_plugin(plugin)
    @@plugins[plugin[:name]] = plugin
  end

  def self.config
    url_root = ENV['RAILS_RELATIVE_URL_ROOT']
    base_config = {
      'markTranslated' => SETTINGS[:mark_translated] || false,
      'relativeUrlRoot' => url_root ? url_root + '/' : '/'
    }

    Bastion.plugins.each do |_name, plugin|
      base_config.merge!(plugin[:config]) if plugin[:config]
    end

    base_config
  end

  def self.localization_path(locale)
    "bastion/angular-i18n/angular-locale_#{locale}.js"
  end
end
