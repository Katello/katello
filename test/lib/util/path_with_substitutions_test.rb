require 'katello_test_helper'

module Katello
  module Util
    class PathWithSubstitutionsTest < ActiveSupport::TestCase
      def setup
        @el5_path = '/content/dist/rhel/server/5/$releasever/$basearch/os'
        @non_sub_path = '/content/dist/rhel/server/5/5Server/x86_64/os'
        @el8_path = '/content/dist/rhel8/8/x86_64/appstream/kickstart'
      end

      def test_substitutions_needed
        assert_equal ['releasever', 'basearch'], PathWithSubstitutions.new(@el5_path, {}).substitutions_needed
        assert_empty PathWithSubstitutions.new(@non_sub_path, {}).substitutions_needed
      end

      def test_substitutable?
        assert PathWithSubstitutions.new(@el5_path, {}).substitutable?
        refute PathWithSubstitutions.new(@non_sub_path, {}).substitutable?
      end

      def test_resolve_token
        path = PathWithSubstitutions.new(@el5_path, 'basearch' => nil, 'releasever' => nil)

        resolved = path.resolve_token("5Server")

        assert_equal "/content/dist/rhel/server/5/5Server/", resolved.base_path
        expected = { 'releasever' => '5Server', 'basearch' => nil }
        assert_equal expected, resolved.substitutions
      end

      def test_unused_substitutions
        assert_equal ['foo'], PathWithSubstitutions.new(@el5_path, 'foo' => 'bar').unused_substitutions
        assert_empty PathWithSubstitutions.new(@el5_path, 'basearch' => 'x86_64').unused_substitutions
        assert_empty PathWithSubstitutions.new(@el8_path, 'basearch' => 'x86_64').unused_substitutions
      end

      def test_apply_substitutions
        assert_equal '/content/dist/rhel/server/5/$releasever/x86_64/os',
                     PathWithSubstitutions.new(@el5_path, 'basearch' => 'x86_64').apply_substitutions
      end
    end
  end
end
