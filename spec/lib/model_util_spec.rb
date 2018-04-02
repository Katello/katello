# encoding: utf-8

require 'katello_test_helper'

module Katello
  class UtilModelSpec < ActiveSupport::TestCase
    include OrchestrationHelper

    describe "labelize tests" do
      specify { Util::Model.labelize("sweet home alabama").must_equal "sweet_home_alabama" }
      specify { Util::Model.labelize("sweet-home+alabama").must_equal "sweet-home_alabama" }
      specify { Util::Model.labelize("sweet home+@#@#alabama").must_equal "sweet_home_alabama" }
      specify { Util::Model.labelize("<t>sweet home alabama</t>").must_equal "_t_sweet_home_alabama_t_" }
      specify { Util::Model.labelize("sweet home 谷歌地球").wont_match(/sweet*/) }
      specify { Util::Model.labelize("sweet home 谷歌地球").must_match(/^[a-zA-Z0-9\-_]+$/) }
      specify { Util::Model.labelize('a' * 129).length.must_be(:<=, 128) }
    end

    describe "setup_label_from_name" do
      before(:each) do
        disable_org_orchestration
        @product = Product.new(:name => "AOL4")
        @product.stubs(:provider).returns({})
        @product.provider.stubs(:redhat_provider?).returns(true)
        @product.stubs(:provider_id).returns(1)
        lib = OpenStruct.new(:library => true)
        @product.stubs(:environments).returns([lib])
      end

      it "should populate label before validation" do
        @product.must_be :valid?
        @product.label.must_equal("AOL4")
      end
    end
  end
end
