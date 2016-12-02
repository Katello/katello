module Katello
  module Util
    class PathWithSubstitutions
      include Comparable

      attr_accessor :substitutions
      attr_accessor :path

      #path /content/rhel/server/$arch/$releasever/os
      #substitutions  {$arch => 'x86_64'}
      def initialize(path, substitutions)
        @substitutions = substitutions
        @path = path
        @resolved = []
      end

      def substitutions_needed
        # e.g. if content_url = "/content/dist/rhel/server/7/$releasever/$basearch/kickstart"
        #      return ['releasever', 'basearch']
        path.split('/').map { |word| word.start_with?('$') ? word[1..-1] : nil }.compact
      end

      def substitutable?
        path =~ /^(.*?)\$([^\/]*)/
      end

      def resolve_substitutions(cdn_resource)
        if @resolved.empty? && path =~ /^(.*?)\$([^\/]*)/
          base_path, var = Regexp.last_match[1], Regexp.last_match[2]
          cdn_resource.fetch_substitutions(base_path).compact.map do |value|
            new_substitutions = substitutions.merge(var => value)
            new_path = path.sub("$#{var}", value)
            @resolved << PathWithSubstitutions.new(new_path, new_substitutions)
          end
        end
        @resolved
      end

      def unused_substitutions
        substitutions.keys.reject do |key|
          path.include?("$#{key}")
        end
      end

      def apply_substitutions
        substitutions.reduce(path) do |url, (key, value)|
          url.gsub("$#{key}", value)
        end
      end

      def <=>(other)
        key1 = path + substitutions.to_s
        key2 = other.path + other.substitutions.to_s
        key1 <=> key2
      end
    end
  end
end
