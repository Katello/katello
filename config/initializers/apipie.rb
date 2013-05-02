# -*- coding: utf-8 -*-
Apipie.configure do |config|
  config.app_name = Katello.config.app_name
  config.app_info = "The sysadmin's fortress."
  config.copyright = "Copyright 2013 Red Hat, Inc."
  config.api_base_url = "/api"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.ignored_by_recorder = %w[Api::V1::PulpProxiesController Api::V1::CandlepinProxiesController Api::V1::RootController, Api::V1::RepositoriesController#sync_complete]
  config.doc_base_url = "/apidoc"
  config.use_cache = Rails.env.production?
  config.validate = false

  unless config.use_cache?
    require 'maruku'
    class Katello::MarkdownMaruku
      def self.to_html(text)
        Maruku.new(text).to_html
      end
    end

    config.markup = Katello::MarkdownMaruku
  end

  if Katello.config.headpin?
    config.ignored = %w[Api::V1::ChangesetsController
                        Api::V1::ChangesetsContentController
                        Api::V1::ErrataController
                        Api::V1::DistributionsController
                        Api::V1::GpgKeysController
                        Api::V1::RepositoriesController
                        Api::V1::PackagesController
                        Api::V1::TasksController
                        Api::V1::TemplatesController
                        Api::V1::TemplatesContentController
                        ]

    config.cache_dir = File.join(Rails.root, "public/headpin-apipie-cache")
  end
end

# special type of validator: we say that it's not specified
class UndefValidator < Apipie::Validator::BaseValidator

  def validate(value)
    true
  end

  def self.build(param_description, argument, options, block)
    if argument == :undef
      self.new(param_description)
    end
  end

  def description
    nil
  end
end

class Apipie::Validator::TypeValidator
  def description
    @type.name
  end
end

class Apipie::Validator::HashValidator
  def description
    "Hash"
  end
end

class NumberValidator < Apipie::Validator::BaseValidator

  def validate(value)
    value.to_s =~ /^(0|[1-9]\d*)$/
  end

  def self.build(param_description, argument, options, block)
    if argument == :number
      self.new(param_description)
    end
  end

  def error
    "Parameter #{param_name} expecting to be a number, got: #{@error_value}"
  end

  def description
    "number."
  end
end

class IdentifierValidator < Apipie::Validator::BaseValidator

  def validate(value)
    value = value.to_s
    value =~ /\A[\w| |_|-]*\Z/ && value.strip == value && (2..128).include?(value.length)
  end

  def self.build(param_description, argument, options, block)
    if argument == :identifier
      self.new(param_description)
    end
  end

  def error
    "Parameter #{param_name} expecting to be an identifier, got: #{@error_value}"
  end

  def description
    "string from 2 to 128 characters containting only alphanumeric characters, space, '_', '-' with no leading or trailing space.."
  end
end

class BooleanValidator < Apipie::Validator::BaseValidator

  def validate(value)
    %w[true false True False].include?(value.to_s)
  end

  def self.build(param_description, argument, options, block)
    if argument == :bool
      self.new(param_description)
    end
  end

  def error
    "Parameter #{param_name} expecting to be a boolean value, got: #{@error_value}"
  end

  def description
    "boolean"
  end
end
