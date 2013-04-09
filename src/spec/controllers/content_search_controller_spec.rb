#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'

describe ContentSearchController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include ProductHelperMethods
  include RepositoryHelperMethods
  include SearchHelperMethods

  before do
    login_user
    set_default_locale
    controller.stub!(:notice)
    controller.stub(:search_validate).and_return(true)
    disable_product_orchestration
    disable_repo_orchestration
  end

  describe "check packages and errata" do
    before (:each) do
      # for these tests we need full user
      login_user :mock => false

      @organization = new_test_org #controller.current_organization
      controller.stub!(:current_organization).and_return(@organization)
      @env1 = KTEnvironment.create!(:name=>"env1", :label=> "env1", :organization => @organization, :prior => @organization.library)
      @env2 = KTEnvironment.create!(:name=>"env2", :label=> "env2", :organization => @organization, :prior => @env1)
      @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM,
                                   :organization => @organization, :repository_url => "https://something.url/stuff")
      @product = Product.new({:name=>"prod", :label=> "prod"})

      @product.provider = @provider
      @product.environments << @organization.library
      @product.stub(:arch).and_return('noarch')
      @product.save!
      ep_library = EnvironmentProduct.find_or_create(@organization.library, @product)

      @repo_library = new_test_repo(ep_library, "repo", "#{@organization.name}/Library/prod/repo")
      @repo = promote(@repo_library, @env1)
      Repository.stub(:search).and_return([@repo])
    end
    after do
      reset_search
    end
    [:packages, :errata].each do |content_type|
      [:all, :shared, :unique].each do |mode|
        context "#{content_type} #{mode} case" do
          before do
            repo_filter_ids = [@repo_library.pulp_id, @repo.pulp_id].collect do |repo|
                  {:term => {:repoids => [repo]}}
            end

            @expected_filters = { :all => {:or => repo_filter_ids},
                                 :shared => {:and => repo_filter_ids}}

            @expected_filters[:unique] ={:and => [@expected_filters[:all],
                                          {:not =>{:filter => @expected_filters[:shared]}}]}
          end

          it "should return some #{content_type}" do
            setup_search(:filter => @expected_filters[mode], :fields =>[:id, :name, :nvrea, :repoids, :type, :errata_id], :results => [])
            params = {"mode"=>mode.to_s, "#{content_type}"=>{"search"=>""}, "content_type"=>"#{content_type}", "repos"=>{"search"=>""}}
            post "#{content_type}", params
            response.should be_success
            result = JSON.parse(response.body)
            result["name"].should == content_type.capitalize.to_s
          end

          it "should return some repo_compare_#{content_type}" do
            result1 = OpenStruct.new(:id => "1000", :nvrea => "foo", :name =>"foo", :repoids => [@repo_library.pulp_id, @repo.pulp_id])
            result2 = OpenStruct.new(:id => "1001", :nvrea => "more foo", :name =>"more foo", :repoids => [@repo_library.pulp_id, @repo.pulp_id])

            #fake type access via hash
            [result1, result2].each do |e|
              e.instance_eval do
                def [](*args)
                  return "security" if args[0].to_sym == :type
                end
              end
            end
            setup_search(:filter => @expected_filters[mode], :results => [result1, result2])

            params = {"mode"=>mode.to_s, "repos"=>{"0"=>{"env_id"=>@repo_library.environment.id.to_s, "repo_id"=>@repo_library.id.to_s}, "1"=>{"env_id"=>@repo.environment.id.to_s, "repo_id"=>@repo.id.to_s}}, "type"=> "compare_#{content_type}" }
            post "repo_compare_#{content_type}", params
            response.should be_success
            result = JSON.parse(response.body)
            result["rows"].should_not be_empty
            result["rows"][0]["id"].should == result1.id
            result["cols"].should_not be_empty
            result["cols"][@repo_library.id.to_s].should_not be_nil
            result["cols"][@repo.id.to_s].should_not be_nil
          end
        end
      end
    end
  end
end
