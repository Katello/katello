require 'katello_test_helper'

module Katello
  module Pulp
    class SimplePackageTest < ActiveSupport::TestCase
      def test_nvrea
        sp = Katello::Pulp::SimplePackage.new(name: 'foo', version: '1.0', release: '1', epoch: 0, arch: 'x86_64')
        assert_equal 'foo-1.0-1.x86_64', sp.nvrea

        sp = Katello::Pulp::SimplePackage.new(name: 'foo', version: '1.0', release: '1', epoch: '0', arch: 'x86_64')
        assert_equal 'foo-1.0-1.x86_64', sp.nvrea

        sp = Katello::Pulp::SimplePackage.new(name: 'foo', version: '1.0', release: '1', epoch: nil, arch: 'x86_64')
        assert_equal 'foo-1.0-1.x86_64', sp.nvrea

        sp = Katello::Pulp::SimplePackage.new(name: 'foo', version: '1.0', release: '1', epoch: 1, arch: 'x86_64')
        assert_equal 'foo-1:1.0-1.x86_64', sp.nvrea
      end
    end
  end
end
