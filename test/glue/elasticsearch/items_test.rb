#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'

class GlueElasticSearchTest < MiniTest::Rails::ActiveSupport::TestCase

  def setup
    @FakeClass = Class.new do
      def self.search
      end

      def self.where(*args)
      end
    end

    @results = MiniTest::Mock.new
    @results.expect(:class, 0)
    @results.expect(:empty?, true)

    @items = Glue::ElasticSearch::Items.new(@FakeClass)
  end

  def test_items
    @results.expect(:total, 0)
    @results.expect(:total, 0)
    @results.expect(:results, [])

    @FakeClass.stub(:search, @results) do
      items, count = @items.retrieve("*")

      assert_empty items
      assert_equal 0, count
    end
  end

  def test_load_records
    @results.expect(:length, 0)
    @results.expect(:order, [], [[]])

    @FakeClass.stub(:where, @results) do
      @items.results = []
      items = @items.load_records

      assert_empty items
    end
  end

  def test_total_items
    filters = []
    @results.expect(:total, 10)

    @FakeClass.stub(:search, @results) do
      total = @items.total_items

      assert_equal 10, total
    end
  end

end
