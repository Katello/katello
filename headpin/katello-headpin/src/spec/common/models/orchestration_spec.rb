require 'spec_helper'
require 'errors'

class UserNotice # needed a class with an AR base
  include Glue

  def process q
    super(q)
  end

  def execute opts = {}
    super(opts)
  end
end

describe Glue do
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

      @queue = Queue.new
      @queue.create(:priority => 3, :action => [@object, :set])
      @queue.create(:priority => 4, :action => [@object_too, :set])

      @object_too.stub(:set).and_return(true)
    end

    specify { lambda {@orchestrated.process(Queue.new) }.should_not raise_error }

    it "should execute pending tasks" do
      @object.should_receive(:set).once.and_return(true)
      @orchestrated.process @queue
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
  end

  context "on save" do
    it "should process queue" do
      @orchestrated.should_receive(:process).once.and_return(true)
      @orchestrated.save
    end
  end

  context "on destroy" do
    before { @orchestrated.save }
    it "should process queue" do
      @orchestrated.should_receive(:process).once.and_return(true)
      @orchestrated.destroy
    end
  end
end