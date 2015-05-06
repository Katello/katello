#
# Finds a route definition that matches a path
#
# ===== Arguments
# * path: actual path to match
# * routes: array of 'routes'
#
# ===== Returns
# Array of two elements:
#
# * index 0: first matching route
# * index 1..n: values for the matched route's variables (in the order they were specified in the route)
#
# ===== Examples
#
#   UrlMatcher.match('/foo', ['/', '/foo', '/bar/baz'])   #=> ['/foo']
#   UrlMatcher.match('/80/07/01', ['/:year/:month/:day']) #=> ['/80/07/01', '80', '07', '01']
#

require 'pathname'

module Katello
  module Util
    module UrlMatcher
      def self.match(path, routes)
        path     = Path.new(path)
        patterns = routes.map { |route| Pattern.new(Array(route).first) }

        patterns.each do |pattern|
          return [pattern.to_s] + pattern.vars if pattern == path
        end

        [nil]
      end

      class Path
        attr_accessor :parts, :ext

        def initialize(path)
          self.parts, self.ext = split_path(path)
        end

        def to_s
          '/' + self.parts.join('/') + self.ext
        end

        private

        def split_path(path)
          path  = path.to_s
          ext   = Pathname(path).extname
          path  = path.sub(/#{ext}$/, '')
          parts = path.split('/').reject { |part| part.empty? }
          [parts, ext]
        end
      end

      class Pattern < Path
        def variables
          return [] unless @match

          a = []
          self.parts.each_with_index do |part, i|
            a << @match.parts[i] if part[0] == ':'
          end
          a << @match.ext[1..-1] if self.ext[1] == ':'
          a
        end
        alias_method :vars, :variables

        def ==(other)
          is_match = size_match?(other) && ext_match?(other) && static_match?(other)
          @match = other if is_match
          is_match
        end

        private

        def size_match?(path)
          self.parts.size == path.parts.size
        end

        def ext_match?(path)
          (self.ext == path.ext) || (self.ext[1] == ':' && !path.ext.empty?)
        end

        def static_match?(path)
          self.parts.each_with_index do |part, i|
            return false unless part[0] == ':' || path.parts[i] == part
          end
          true
        end
      end
    end
  end
end
