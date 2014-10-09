MiniTest::Spec.class_eval do
  def self.shared_examples
    @shared_examples ||= {}
  end
end

module MiniTest::Spec::SharedExamples
  def shared_examples_for(desc, &block)
    MiniTest::Spec.shared_examples[desc] = block
  end

  def it_should_behave_like(desc)
    describe desc do
      instance_eval { MiniTest::Spec.shared_examples[desc] }
    end
  end
end

Object.class_eval { include(MiniTest::Spec::SharedExamples) }
