module Katello
  module Util
    module Data
      def self.array_with_indifferent_access(variable)
        variable.map { |x| x.with_indifferent_access }
      end

      def self.ostructize(obj, options = {})
        options[:prefix_keys] ||= []
        options[:prefix]      ||= '_'

        if obj.is_a? Hash

          ostructized_hash = {}
          obj.each do |key, value|
            if options[:prefix_keys].include? key
              new_key = (options[:prefix].to_s + key.to_s).to_sym
            else
              new_key = key
            end

            if Object.respond_to? new_key
              fail "Error occured while converting Hash to OpenStruct. Key '%s' conflicts with method OpenStruct#%s." % [new_key, new_key]
            end

            ostructized_hash[new_key] = ostructize(value, options)
          end
          return OpenStruct.new ostructized_hash

        elsif obj.is_a? Array

          return obj.map { |r| ostructize(r, options) }

        end
        return obj
      end
    end
  end
end
