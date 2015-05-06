# various user-configurable mappings defined in /etc/katello/mapping.yml

require 'yaml'

module Katello
  module Mapping
    def self.configuration
      return @config if @config
      mapping_file = '/etc/katello/mapping.yml'
      if File.readable?(mapping_file)
        @config = YAML.load_file(mapping_file)
      else
        @config = {}
      end
    end

    class ImageFactoryNaming
      def self.translate(name = '', version = '')
        matched_name = "#{name} #{version}"
        naming = Mapping.configuration['imagefactory_naming'] || {}
        naming.each do |key, values|
          regexp_str = "^#{Regexp.escape(key).gsub('\*', '.*')}$"
          if Regexp.new(regexp_str) =~ matched_name
            return values.map(&:to_s)
          end
        end
        return [name.to_s, version.to_s]
      end
    end
  end
end
