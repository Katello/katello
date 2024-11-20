module Katello
  module Validators
    class AlternateContentSourcePathValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value
          case attribute
          when :base_url
            unless AlternateContentSourcePathValidator.validate_base_url(value)
              record.errors.add(attribute, N_("%s is not a valid path") % value)
            end
          when :subpaths
            unless AlternateContentSourcePathValidator.validate_subpaths(value)
              record.errors.add(attribute, N_('All subpaths must have a slash at the end and none at the front'))
            end
          end
        end
      end

      def self.validate_base_url(base_url)
        base_url =~ /\A(?!uln:\/\/)(#{URI::DEFAULT_PARSER.make_regexp})\z/
      end

      # Subpaths must have a slash at the end and none at the front: 'path/'
      def self.validate_subpaths(subpaths)
        bad_subpaths = subpaths.select { |subpath| subpath[0] == '/' || subpath[-1] != '/' }
        bad_subpaths.empty?
      end
    end
  end
end
