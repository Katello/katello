require 'katello_test_helper'

module Katello
  module Util
    class PathWithSubstitutionsTest < ActiveSupport::TestCase
      def setup
        @el5_path = '/content/dist/rhel/server/5/$releasever/$basearch/os'
        @releasever_list = ['5Server', '5.8']
        @arch_list = ['x86_64', 'i386']
      end

      def test_no_substitute_vars
        cdn_var = CdnVarSubstitutor.new(mock)
        path = '/no/substitutions/apply'

        list = cdn_var.substitute_vars(path)
        assert_equal 1, list.count
        assert_equal path, list.first.path
      end

      def test_empty_substitute_vars
        cdn_var = CdnVarSubstitutor.new(mock)

        unresolved = PathWithSubstitutions.new(@el5_path, {})
        unresolved.expects(:resolve_substitutions).returns([])

        PathWithSubstitutions.expects(:new).with(unresolved.path, unresolved.substitutions).returns(unresolved)

        assert_empty cdn_var.substitute_vars(@el5_path)
      end

      def test_substitute_vars
        cdn_var = CdnVarSubstitutor.new(mock)

        five_server_x86_64 = PathWithSubstitutions.new('/content/dist/rhel/server/5/5Server/x86_64/os',
                                                       'releasever' => '5Server', 'basearch' => 'x86_64')
        five_server = PathWithSubstitutions.new('/content/dist/rhel/server/5/5Server/$basearch/os', 'releasever' => '5Server')
        five_server.expects(:resolve_substitutions).returns([five_server_x86_64])

        five_point_eight_i386 = PathWithSubstitutions.new('/content/dist/rhel/server/5/5.8/i386/os',
                                                          'releasever' => '5.8', 'basearch' => 'i386')
        five_point_eight = PathWithSubstitutions.new('/content/dist/rhel/server/5/5.8/$basearch/os', 'releasever' => '5.8')
        five_point_eight.expects(:resolve_substitutions).returns([five_point_eight_i386])

        unresolved = PathWithSubstitutions.new(@el5_path, {})
        unresolved.expects(:resolve_substitutions).returns([five_server, five_point_eight])

        PathWithSubstitutions.stubs(:new).with(unresolved.path, unresolved.substitutions).returns(unresolved)
        PathWithSubstitutions.stubs(:new).with(five_server.path, five_server.substitutions).returns(five_server)
        PathWithSubstitutions.stubs(:new).with(five_point_eight.path, five_point_eight.substitutions).returns(five_point_eight)

        resolved_list = cdn_var.substitute_vars(@el5_path)
        assert_equal [five_server_x86_64, five_point_eight_i386].sort, resolved_list.sort
      end
    end
  end
end
