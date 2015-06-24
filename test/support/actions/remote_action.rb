module Support
  module Actions
    module RemoteAction
      def stub_remote_user(admin = false)
        if admin
          User.current = users(:admin)
        else
          User.current = users(:one)
        end
      end

      # runcible_expects(action, :extensions, :consumer, :create).with('uuid')
      # will check that pulp_extensions.consumer.create('uuid') was called in the
      # action.
      def runcible_expects(action, entry_method, *method_chain)
        method_chain = method_chain.dup
        if [:resources, :extensions].include?(entry_method)
          method_chain.unshift "pulp_#{entry_method}"
        else
          fail "Unexpected entry method: #{entry_method}"
        end
        last_method = method_chain.pop
        last_stub = method_chain.reduce(action) do |target, method|
          stub(method).tap { |next_stub| target.expects(method).returns(next_stub) }
        end
        last_stub.expects(last_method)
      end
    end
  end
end
