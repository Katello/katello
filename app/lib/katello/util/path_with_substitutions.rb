module Katello
  module Util
    class PathWithSubstitutions
      include Comparable

      attr_reader :base_path, :path, :substitutions

      SUBSTITUTABLE_REGEX = /^(.*?)\$([^\/]*)/.freeze

      #path /content/rhel/server/$arch/$releasever/os
      #substitutions  {$arch => 'x86_64'}
      def initialize(path, substitutions)
        @substitutions = substitutions
        @path = path

        if @path =~ SUBSTITUTABLE_REGEX
          @base_path, @token = Regexp.last_match[1], Regexp.last_match[2]
        end
      end

      def split_path
        @split ||= path.split('/')
      end

      def substitutions_needed
        # e.g. if content_url = "/content/dist/rhel/server/7/$releasever/$basearch/kickstart"
        #      return ['releasever', 'basearch']
        split_path.map { |word| word.start_with?('$') ? word[1..] : nil }.compact
      end

      def substitutable?
        @token.present?
      end

      def resolve_token(value)
        new_substitutions = substitutions.merge(@token => value)
        new_path = path.sub("$#{@token}", value)
        PathWithSubstitutions.new(new_path, new_substitutions)
      end

      def unused_substitutions
        substitutions.keys.reject do |key|
          path.include?("$#{key}") || split_path.include?(substitutions[key])
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
