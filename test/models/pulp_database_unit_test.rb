# encoding: utf-8

require 'katello_test_helper'

module Katello
  class PulpDatabaseUnitTest < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def test_complete_for
      content_types = ::Katello::RepositoryTypeManager.enabled_repository_types.values.map { |t| t.content_types.map(&:model_class) }.flatten.select { |klazz| klazz <= ::Katello::Concerns::PulpDatabaseUnit }
      content_types.each do |klazz|
        if klazz.many_repository_associations
          refute_nil klazz.complete_for("repository="), "asserting #{klazz}"
          refute_nil klazz.search_for("repository=foo"), "asserting #{klazz}"
        end
      end

      assert_empty ::Katello::YumMetadataFile.methods.grep(/complete_for/)
    end
  end
end
