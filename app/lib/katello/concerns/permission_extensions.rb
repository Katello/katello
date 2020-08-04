module Katello
  module Concerns
    module PermissionExtensions
      extend ActiveSupport::Concern

      attr_accessor :finder_scope

      def initialize(name, hash, options)
        super(name, hash, options)
        @finder_scope = options[:finder_scope]
      end
    end
  end
end
