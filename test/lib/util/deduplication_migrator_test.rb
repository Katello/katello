require 'katello_test_helper'

module Katello
  module Util
    class DeduplicationMigratorTest < ActiveSupport::TestCase
      let(:migrator) do
        Katello::Util::DeduplicationMigrator.new
      end

      let(:model) do
        {
          :model => ::Katello::CapsuleLifecycleEnvironment,
          :fields => [:lifecycle_environment_id, :capsule_id],
        }
      end

      let(:content_view) do
        {
          :model => ::Katello::ContentView,
          :fields => [:name, :organization_id],
        }
      end

      let(:duplicate_content_view) do
        FactoryBot.build(:katello_content_view, :organization_id => 1, :name => 'My CV', id: 499)
      end

      def test_cleaning_queries
        mock_relation = model[:model].none
        model[:model]
          .expects(:group).with(model[:fields])
          .returns(mock_relation)
        ActiveRecord::Relation.any_instance
          .expects(:having).with("count(*) > 1")
          .returns(mock_relation)
        ActiveRecord::Relation.any_instance
          .expects(:count)
          .returns({
                     [1, 1] => 2,
                     [6, 1] => 2,
                   })
        mock_relation
          .expects(:pluck).with('min(id)')
          .returns([1, 6])
        result = migrator.cleaning_queries(model)
        expected = [
          {:lifecycle_environment_id => 1, :capsule_id => 1, :min_id => 1},
          {:lifecycle_environment_id => 6, :capsule_id => 1, :min_id => 6}
        ]
        assert_equal result, expected
      end

      def test_clean_duplicates
        model_class = model[:model]
        mock_relation = model_class.none
        query = {:lifecycle_environment_id => 6, :capsule_id => 1, :min_id => 6}
        model_class.expects(:where).with(query).returns(mock_relation)
        mock_relation.expects(:where).returns(mock_relation)
        mock_relation.expects(:not).with(id: 6).returns(mock_relation)
        mock_relation.expects(:delete_all).returns 2

        result = migrator.clean_duplicates(query, model_class)
        assert_equal result, 2
      end

      def test_rename_duplicates
        model_class = content_view[:model]
        mock_relation = model_class.none
        query = {:name => 'My CV', :organization_id => 1, :min_id => 7}
        dup_cv = duplicate_content_view
        model_class.expects(:where).with(query).returns(mock_relation)
        mock_relation.expects(:where).returns(mock_relation)
        mock_relation.expects(:not).with(id: 7).returns([dup_cv])
        mock_relation.expects(:delete_all).never

        dup_cv.expects(:name).twice.returns('My CV')
        dup_cv.expects(:name=).with("My CV_#{dup_cv.id}")
        dup_cv.expects(:save).with(:validate => false)

        result = migrator.rename_duplicates(query, model_class)
        assert_equal result, 1
      end

      def test_execute
        migrator.expects(:cleaning_queries).at_least(5).returns(
        [
          {:lifecycle_environment_id => 1, :capsule_id => 1, :min_id => 1},
          {:lifecycle_environment_id => 6, :capsule_id => 1, :min_id => 6}
        ])
        migrator.expects(:clean_duplicates).at_least(5).returns(5)
        migrator.expects(:rename_duplicates).at_least_once.returns(1)

        result = migrator.execute!
        assert_equal result, true
      end
    end
  end
end
