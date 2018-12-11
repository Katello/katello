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
        create_rhel_eight_substitutions
      end

      def split_path
        @split ||= @path.split('/').reject(&:blank?)
      end

      def substitutions_needed
        # e.g. if content_url = "/content/dist/rhel/server/7/$releasever/$basearch/kickstart"
        #      return ['releasever', 'basearch']
        split_path.map { |word| word.start_with?('$') ? word[1..-1] : nil }.compact
      end

      def create_rhel_eight_substitutions
        @substitutions["basearch"] = rhel_eight_arch if rhel_eight?
      end

      def rhel_eight?
        # url for RHEL8 repos can be either format:
        # /content/dist/rhel8/8.0/x86_64/baseos/os/ OR
        # /content/dist/layered/rhel8/x86_64/product
        rhel8 = "rhel8"
        split_path[2] == rhel8 || split_path[3] == rhel8
      end

      def rhel_eight_arch
        # arch for RHEL8 repo paths is always the in the 5th position of the url i.e.
        # /content/dist/rhel8/8.0/x86_64/baseos/os/ OR
        split_path[4]
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
