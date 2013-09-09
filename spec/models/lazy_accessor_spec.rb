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

require 'spec_helper'

describe LazyAccessor do

  class Something < Notice # needed a class with an AR base
    include LazyAccessor

    DEFAULT_VALUE = 1
    ANOTHER_VALUE = 2

    attr_writer :run_b_initializer

    lazy_accessor :a, :initializer => lambda {|s| init_a }
    lazy_accessor :b, :initializer => lambda {|s| init_b }, :unless => lambda {|s| true }
    def init_a
      DEFAULT_VALUE
    end
    def init_b
      DEFAULT_VALUE
    end
  end

  context "For an existing record" do
    before do
      @c = Something.new
      @c.stub!(:new_record?).and_return(false)
    end

    it "should call initializer when instance variable is nil" do
      @c.a.should == Something::DEFAULT_VALUE
    end

    it "shouldn't call initializer when instance variable is not nil" do
      @c.a = Something::ANOTHER_VALUE
      @c.a.should == Something::ANOTHER_VALUE
    end

    it "shouldn't call initializer unless evaluates to true" do
      @c.run_b_initializer = false
      @c.b.should be_nil
    end

    it "shouldn't call initializer if :unless evaluates to false but instance variable is set" do
      @c.run_b_initializer = false
      @c.b = Something::ANOTHER_VALUE
      @c.b.should == Something::ANOTHER_VALUE
    end

    it "should mark changed attribute as dirty" do
      @c.a = Something::ANOTHER_VALUE
      @c.a_changed?.should be_true
    end

    it "should mark object dirty" do
      @c.a = Something::ANOTHER_VALUE
      @c.remote_attribute_changed?('a').should be_true
    end

    it "should return the change" do
      @c.a = Something::ANOTHER_VALUE
      @c.a_change.should == [Something::DEFAULT_VALUE, Something::ANOTHER_VALUE]
    end

    it "should cache the old value after changes were retrieved" do
      @c.a = Something::ANOTHER_VALUE
      @c.a_change
      @c.changed_remote_attributes['a'].should == Something::DEFAULT_VALUE
    end

    it "should return previous value" do
      @c.a = Something::ANOTHER_VALUE
      @c.a_was.should == Something::DEFAULT_VALUE
    end

    it "should mark object dirty after changes" do
      @c.a = Something::ANOTHER_VALUE
      @c.changed_remote_attributes.should_not be_empty
    end
  end
end
