# encoding: utf-8

require 'katello_test_helper'

module Katello
  class PulpDatabaseUnitTest < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def test_complete_for
      content_types = ::Katello::RepositoryTypeManager.enabled_repository_types.values.map { |t| t.content_types.map(&:model_class) }.flatten.select { |klazz| klazz <= ::Katello::Concerns::PulpDatabaseUnit }
      content_types.each do |klazz|
        refute_nil klazz.complete_for("repository="), "asserting #{klazz}"
        refute_nil klazz.search_for("repository=foo"), "asserting #{klazz}"
      end
    end

    def test_orphaned
      river = katello_module_streams(:river)
      river.repository_module_streams.destroy_all
      one = katello_module_streams(:one)
      unless one.repositories.include?(katello_repositories(:fedora_17_x86_64))
        fail 'Ensure that one.repositories includes :fedora_17_x86_64'
      end

      assert_includes ::Katello::ModuleStream.orphaned, river
      refute_includes ::Katello::ModuleStream.orphaned, one
    end
  end
end
