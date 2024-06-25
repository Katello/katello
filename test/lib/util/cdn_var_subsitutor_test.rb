require 'katello_test_helper'

FakeContent = Struct.new(:name, :content_url)

module Katello
  module Util
    class CdnVarSubstitutorTest < ActiveSupport::TestCase
      class ResourceWithSubstitutions
        def fetch_substitutions(path)
        end
      end

      class ResourceWithoutSubstitutions
        def fetch_paths(path)
        end
      end

      def setup
        @el5_path = '/content/dist/rhel/server/5/$releasever/$basearch/os'
        @el5_base_path = '/content/dist/rhel/server/5/'
        @releasever_list = ['5Server', '5.8']
        @arch_list = ['x86_64', 'i386']
        @resource = ResourceWithSubstitutions.new
      end

      def test_no_substitute_vars
        cdn_var = CdnVarSubstitutor.new(@resource)
        path = '/no/substitutions/apply'

        list = cdn_var.substitute_vars(path)
        assert_equal 1, list.count
        assert_equal path, list.first.path
      end

      def test_empty_substitute_vars
        cdn_var = CdnVarSubstitutor.new(@resource)

        @resource.expects(:fetch_substitutions).with(@el5_base_path).returns([])

        assert_empty cdn_var.substitute_vars(@el5_path)
      end

      def test_substitute_vars
        cdn_var = CdnVarSubstitutor.new(@resource)

        five_server_x86_64 = PathWithSubstitutions.new('/content/dist/rhel/server/5/5Server/x86_64/os',
                                                       'releasever' => '5Server', 'basearch' => 'x86_64')

        five_point_eight_i386 = PathWithSubstitutions.new('/content/dist/rhel/server/5/5.8/i386/os',
                                                          'releasever' => '5.8', 'basearch' => 'i386')

        @resource.expects(:fetch_substitutions).with(@el5_base_path).returns(['5Server', '5.8'])
        @resource.expects(:fetch_substitutions).with(@el5_base_path + '5Server/').returns(['x86_64'])
        @resource.expects(:fetch_substitutions).with(@el5_base_path + '5.8/').returns(['i386'])

        resolved_list = cdn_var.substitute_vars(@el5_path)

        assert_equal [five_server_x86_64, five_point_eight_i386].sort, resolved_list.sort
      end

      def test_substitute_vars_paths_without_substitutions
        resource = ResourceWithoutSubstitutions.new
        cdn_var = CdnVarSubstitutor.new(resource)

        response = [
          {
            path: '/content/dist/rhel/server/5/5.8/i386/os',
            substitutions: {
              releasever: '5.8',
              basearch: 'i386',
            },
          },
          {
            path: '/content/dist/rhel/server/5/5Server/x86_64/os',
            substitutions: {
              releasever: '5Server',
              basearch: 'x86_64',
            },
          }
        ]

        resource.expects(:fetch_paths).with(@el5_path).returns(response)

        resolved_list = cdn_var.substitute_vars(@el5_path)

        expected_paths = [
          PathWithSubstitutions.new('/content/dist/rhel/server/5/5.8/i386/os', releasever: '5.8', basearch: 'i386'),
          PathWithSubstitutions.new('/content/dist/rhel/server/5/5Server/x86_64/os', releasever: '5Server', basearch: 'x86_64')
        ]

        assert_equal expected_paths.sort, resolved_list.sort
      end

      def test_validating_subscriptions_unused_params
        fake_content_params = ["Red Hat Enterprise Linux Atomic Host (Kickstart)",
                               "/content/dist/rhel/atomic/7/7Server/x86_64/kickstart"]
        content = FakeContent.new(*fake_content_params)
        substitutions = { "basearch": "Unspecified" }
        error_message = "#{substitutions.keys.join(",")} cannot be specified for #{content.name}"\
                        " as that information is not substitutable in #{content.content_url}"
        check_validating_subscriptions(content, substitutions, error_message)
      end

      def test_validating_subscriptions_needs_params
        fake_content_params = ["Red Hat Enterprise Linux Atomic Host (Kickstart)",
                               "/content/dist/$basearch/atomic/7/7Server/x86_64/kickstart"]
        content = FakeContent.new(*fake_content_params)
        substitutions = {}
        error_message = "Missing arguments basearch for #{content.content_url}"
        check_validating_subscriptions(content, substitutions, error_message)
      end

      def check_validating_subscriptions(content, substitutions, error_message)
        cdn_var = CdnVarSubstitutor.new(mock)
        assert_raises_with_message(Errors::CdnSubstitutionError, error_message) do
          cdn_var.validate_substitutions(content, substitutions)
        end
      end
    end
  end
end
