module Support
  module Actions
    # Module for creating actions based on yaml fixtures.
    #
    # Usage:
    #
    # Given action +Actions::Pulp::Consumer::ContentInstall+
    # and files +test/fixtures/actions/pulp/consumer/content_install/input.yaml+
    # and +test/fixtures/actions/pulp/consumer/content_install/success.yaml+
    # calling:
    #
    #     fixture_action(Actions::Pulp::Consumer::ContentInstall,
    #                    input: :input,
    #                    output: :success)
    #
    # will create new action with the data from those files. The
    # stubbed data can be passed directly if needed.
    #
    #      fixture_action(Actions::Pulp::Consumer::ContentInstall,
    #                    input: { some_input: 1 }',
    #                    output: { some_output: 2 })
    module Fixtures
      include Dynflow::Testing

      def fixture_action(action_class, options = {})
        create_action(action_class).tap do |action|
          fixture_interface(action, :input, options[:input])
          fixture_interface(action, :output, options[:output])
        end
      end

      def interface_fixture_file(action, variant)
        action_path = action.class.name.underscore.sub('actions/', '')
        action_path << "/#{variant}.yaml"
        fixture_file(action_path)
      end

      def fixture_interface(action, method, data)
        if data.is_a? Symbol
          data = fixture_data(interface_fixture_file(action, data))
        end
        action.stubs(method => data.with_indifferent_access) if data
      end

      def fixture_file(path)
        File.join(Katello::Engine.root, 'test/fixtures/actions', path)
      end

      def fixture_data(path)
        path = fixture_file(path) unless path =~ /\A\//
        YAML.load_file(path).with_indifferent_access
      end
    end
  end
end
