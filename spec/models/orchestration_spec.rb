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
require 'errors'

describe Glue do
  class UserNotice < ActiveRecord::Base # needed a class with an AR base
    include Glue

    def process q
      super(q)
    end

    def execute opts = {}
      super(opts)
    end
  end

  before { @orchestrated = UserNotice.new }

  context "orchestration_for method" do
    it "should return :create for a new record" do
      @orchestrated.orchestration_for.should == :create
    end

    it "should return :update for record being updated" do
      @orchestrated.save
      @orchestrated.orchestration_for.should == :update
    end

    it "should return :destroy for the record that is being deleted" do
      @orchestrated.save
      @orchestrated.stub!(:on_destroy).and_return(true)

      @orchestrated.destroy
      @orchestrated.orchestration_for.should == :destroy
    end

    it "should return originally set value" do
      @orchestrated.orchestration_for = :blah
      @orchestrated.orchestration_for.should == :blah
    end
  end

  context "execute method" do
    before { @object = Object.new }

    it "should execute method without parameters" do
      @object.should_receive(:set).once.and_return(true)
      @orchestrated.execute(:action => [@object, "set"])
    end

    it "should execute method with parameters" do
      @object.should_receive(:set).with(1, 2, 3).once.and_return(true)
      @orchestrated.execute(:action => [@object, "set", 1, 2, 3])
    end

    context "on rollback" do
      it "should execute del method instead of set" do
        @object.should_receive(:del).once.and_return(true)
        @orchestrated.execute(:action => [@object, "set"], :rollback => true)
      end

      it "should execute set method instead of del" do
        @object.should_receive(:set).once.and_return(true)
        @orchestrated.execute(:action => [@object, "del"], :rollback => true)
      end
    end

    it "should raise exception if requested method doesn't exist" do
      lambda {@orchestrated.execute(:action => [@object, "blah"])}.should raise_error(Errors::OrchestrationException)
    end
  end

  context "queue processing" do
    before do
      @object = Object.new
      @object_too = Object.new
      @object_foo = Object.new

      @queue = Glue::Queue.new
      @task_1 = @queue.create(:priority => 3, :action => [@object, :set])
      @task_2 = @queue.create(:priority => 4, :action => [@object_too, :set])
      @next_queue = Glue::Queue.new(@queue)
      @task_3 = @next_queue.create(:priority => 1, :action => [@object_foo, :set])

      [@object, @object_too, @object_foo].each { |o| o.stub(:set => true, :pretty_print => "mock") }
    end

    specify { lambda {@orchestrated.process(Glue::Queue.new) }.should_not raise_error }

    it "should execute pending tasks" do
      @object.should_receive(:set).once.and_return(true)
      @object_too.should_receive(:set).once.and_return(true)
      @object_foo.should_receive(:set).once.and_return(true)
      @orchestrated.process @queue
      @orchestrated.process @next_queue
    end

    it "should change the status of successfully completed task to 'completed'" do
      @queue.completed.size.should == 0
      @queue.pending.size.should == 2

      @object.stub(:set).and_return(true)
      @orchestrated.process @queue

      @queue.pending.size.should == 0
      @queue.completed.size.should == 2
    end

    it "should raise an exception if failed tasks are present" do
      @object.stub(:set).and_return(false)
      lambda { @orchestrated.process @queue }.should raise_error
    end

    it "should raise an exception if there are errors present" do
      @orchestrated.errors.add(:base, "blah")
      @object.stub(:set).and_return(true)
      lambda { @orchestrated.process @queue }.should raise_error
    end

    it "should perform rollback of completed tasks on error" do
      @object_too.stub(:set).and_return(false)
      @object.stub(:set).and_return(true)
      @object.should_receive(:del).once.and_return(true)

      @orchestrated.process @queue rescue nil
    end

    it "should perform rollback of aslo on previous queues" do
      @object_foo.stub(:set).and_return(false)
      @object_too.should_receive(:del).once.and_return(true)
      @object.should_receive(:del).once.and_return(true)

      @orchestrated.process @next_queue rescue nil
    end

    it "should order the tasks by priority in scope of one queue." do
      @next_queue.all.should == [@task_1, @task_2, @task_3]
    end
  end

  context "on save" do
    it "should process queue" do
      @orchestrated.should_receive(:process).twice.and_return(true)
      @orchestrated.save
    end
  end

  context "on destroy" do
    before { @orchestrated.save }
    it "should process queue" do
      @orchestrated.should_receive(:process).twice.and_return(true)
      @orchestrated.destroy
    end
  end
end
