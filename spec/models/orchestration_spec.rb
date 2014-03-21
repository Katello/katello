#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'
require 'katello/errors'

module Katello
describe Glue do
  class UserNotice < Katello::Model # needed a class with an AR base
    include Glue

    def process q
      super(q)
    end

    def execute opts = {}
      super(opts)
    end
  end

  before { @orchestrated = UserNotice.new }

  describe "orchestration_for method" do
    it "should return :create for a new record" do
      @orchestrated.orchestration_for.must_equal(:create)
    end

    it "should return :update for record being updated" do
      @orchestrated.save
      @orchestrated.orchestration_for.must_equal(:update)
    end

    it "should return :destroy for the record that is being deleted" do
      @orchestrated.save
      @orchestrated.stubs(:on_destroy).returns(true)

      @orchestrated.destroy
      @orchestrated.orchestration_for.must_equal(:destroy)
    end

    it "should return originally set value" do
      @orchestrated.orchestration_for = :blah
      @orchestrated.orchestration_for.must_equal(:blah)
    end
  end

  describe "execute method" do
    before { @object = Object.new }

    it "should execute method without parameters" do
      @object.expects(:set).once.returns(true)
      @orchestrated.execute(:action => [@object, "set"])
    end

    it "should execute method with parameters" do
      @object.expects(:set).with(1, 2, 3).once.returns(true)
      @orchestrated.execute(:action => [@object, "set", 1, 2, 3])
    end

    describe "on rollback" do
      it "should execute del method instead of set" do
        @object.expects(:del).once.returns(true)
        @orchestrated.execute(:action => [@object, "set"], :rollback => true)
      end

      it "should execute set method instead of del" do
        @object.expects(:set).once.returns(true)
        @orchestrated.execute(:action => [@object, "del"], :rollback => true)
      end
    end

    it "should raise exception if requested method doesn't exist" do
      lambda {@orchestrated.execute(:action => [@object, "blah"])}.must_raise(Errors::OrchestrationException)
    end
  end

  describe "queue processing" do
    before do
      @object = Object.new
      @object_too = Object.new
      @object_foo = Object.new

      @queue = Glue::Queue.new
      @task_1 = @queue.create(:priority => 3, :action => [@object, :set])
      @task_2 = @queue.create(:priority => 4, :action => [@object_too, :set])
      @next_queue = Glue::Queue.new(@queue)
      @task_3 = @next_queue.create(:priority => 1, :action => [@object_foo, :set])

      [@object, @object_too, @object_foo].each { |o| o.stubs(:set).returns(true).stubs(:pretty_print).returns("mock") }
    end

    it "should execute pending tasks" do
      @object.expects(:set).once.returns(true)
      @object_too.expects(:set).once.returns(true)
      @object_foo.expects(:set).once.returns(true)
      @orchestrated.process @queue
      @orchestrated.process @next_queue
    end

    it "should change the status of successfully completed task to 'completed'" do
      @queue.completed.size.must_equal(0)
      @queue.pending.size.must_equal(2)

      @object.stubs(:set).returns(true)
      @orchestrated.process @queue

      @queue.pending.size.must_equal(0)
      @queue.completed.size.must_equal(2)
    end

    it "should raise an exception if failed tasks are present" do
      @object.stubs(:set).returns(false)
      lambda { @orchestrated.process @queue }.must_raise(Errors::OrchestrationException)
    end

    it "should raise an exception if there are errors present" do
      @orchestrated.errors.add(:base, "blah")
      @object.stubs(:set).returns(true)
      lambda { @orchestrated.process @queue }.must_raise(Errors::OrchestrationException)
    end

    it "should perform rollback of completed tasks on error" do
      @object_too.stubs(:set).returns(false)
      @object.stubs(:set).returns(true)
      @object.expects(:del).once.returns(true)

      @orchestrated.process @queue rescue nil
    end

    it "should perform rollback of aslo on previous queues" do
      @object_foo.stubs(:set).returns(false)
      @object_too.expects(:del).once.returns(true)
      @object.expects(:del).once.returns(true)

      @orchestrated.process @next_queue rescue nil
    end

    it "should order the tasks by priority in scope of one queue." do
      @next_queue.all.must_equal([@task_1, @task_2, @task_3])
    end
  end

  describe "on save" do
    it "should process queue" do
      @orchestrated.expects(:process).twice.returns(true)
      @orchestrated.save
    end
  end

  describe "on destroy" do
    before { @orchestrated.save }
    it "should process queue" do
      @orchestrated.expects(:process).twice.returns(true)
      @orchestrated.destroy
    end
  end
end
end
