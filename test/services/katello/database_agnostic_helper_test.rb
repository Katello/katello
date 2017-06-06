require 'katello_test_helper'

module Katello
  describe DatabaseAgnosticHelper do
    describe DatabaseAgnosticHelper::PostgreSQL do
      before(:each) do
        ActiveRecord::Base.connection.stubs(:adapter_name).returns('PostgreSQL')
        load 'katello/database_agnostic_helper.rb'
        class DatabaseAgnosticHelperTester
          extend DatabaseAgnosticHelper
        end
      end

      it 'concats with || characters' do
        assert_equal("(foo || bar)", DatabaseAgnosticHelperTester.concat('foo', 'bar'))
      end
    end

    describe DatabaseAgnosticHelper::MySQL do
      before(:each) do
        ActiveRecord::Base.connection.stubs(:adapter_name).returns('MySQL')
        load 'katello/database_agnostic_helper.rb'
        class DatabaseAgnosticHelperTester
          extend DatabaseAgnosticHelper
        end
      end

      it 'concats with the CONCAT function' do
        assert_equal("CONCAT(foo, bar)", DatabaseAgnosticHelperTester.concat('foo', 'bar'))
      end
    end
  end
end
