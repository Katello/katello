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
