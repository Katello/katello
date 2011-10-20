require 'spec_helper'

describe FiltersController do


  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper


  describe "Controller tests" do
    before(:each) do
      set_default_locale
      login_user

      @organization = new_test_org

      @filter = Filter.new(:name => 'filter', :organization => @organization)
      @filter.stub("description").and_return("")

      Filter.stub(:search_for).and_return(Filter)
      Filter.stub(:limit).and_return([@filter])
      
      

    end

    describe "GET index" do

      it "requests system template using search criteria" do
        #Filter.should_receive(:search_for) {Filter}
        Filter.stub_chain(:where, :limit)
        get :index
        response.should be_success
      end

    end
  end


  


end
