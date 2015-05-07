# encoding: UTF-8

require 'katello_test_helper'

module Katello
  describe ProductsController do
    include LocaleHelperMethods
    include OrganizationHelperMethods

    describe "(katello)" do
      before do
        setup_controller_defaults
        @organization = get_organization
      end

      describe "get auto_complete_product" do
        before :each do
          Product.expects(:search).once.returns([OpenStruct.new(:name => "a", :id => 100)])
        end

        it 'should succeed' do
          get :auto_complete, :term => "a"
          must_respond_with(:success)
        end
      end
    end
  end
end
