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

module Katello
  module Apipie
    module Validators
      class IdentifierValidator < ::Apipie::Validator::BaseValidator
        def validate(value)
          value = value.to_s
          value =~ /\A[\w| |_|-]*\Z/ && value.strip == value && (2..128).include?(value.length)
        end

        def self.build(param_description, argument, _options, _block)
          if argument == :identifier
            self.new(param_description)
          end
        end

        def error
          "Parameter #{param_name} expecting to be an identifier, got: #{@error_value}"
        end

        def description
          "string from 2 to 128 characters containing only alphanumeric characters, space, '_', '-' with no leading or trailing space.."
        end
      end
    end
  end
end
