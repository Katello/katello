require 'katello_test_helper'

module Katello
  describe LazyAccessor do
    class Something < Provider # needed a class with an AR base
      include LazyAccessor

      DEFAULT_VALUE = 1
      ANOTHER_VALUE = 2

      attr_writer :run_b_initializer

      lazy_accessor :a, :initializer => lambda { |_s| init_a }
      lazy_accessor :b, :initializer => lambda { |_s| init_b }, :unless => lambda { |_s| true }
      def init_a
        DEFAULT_VALUE
      end

      def init_b
        DEFAULT_VALUE
      end
    end

    describe "For an existing record" do
      before do
        @c = Something.new
        @c.stubs(:new_record?).returns(false)
      end

      it "should call initializer when instance variable is nil" do
        value(@c.a).must_equal(Something::DEFAULT_VALUE)
      end

      it "shouldn't call initializer when instance variable is not nil" do
        @c.a = Something::ANOTHER_VALUE
        value(@c.a).must_equal(Something::ANOTHER_VALUE)
      end

      it "shouldn't call initializer unless evaluates to true" do
        @c.run_b_initializer = false
        value(@c.b).must_be_nil
      end

      it "shouldn't call initializer if :unless evaluates to false but instance variable is set" do
        @c.run_b_initializer = false
        @c.b = Something::ANOTHER_VALUE
        value(@c.b).must_equal(Something::ANOTHER_VALUE)
      end
    end
  end
end
