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

require 'katello_test_helper'

module Katello
  describe ContentSearchController do

    include LocaleHelperMethods
    include OrganizationHelperMethods
    include AuthorizationHelperMethods
    include ProductHelperMethods
    include RepositoryHelperMethods
    include SearchHelperMethods

    before do
      setup_controller_defaults
      @controller.stubs(:notice)
      @controller.stubs(:search_validate).returns(true)
      disable_product_orchestration
      disable_repo_orchestration
    end

    describe "check packages and errata" do
      before (:each) do

        @organization = new_test_org #controller.current_organization
        @controller.stubs(:current_organization).returns(@organization)
        @env1 = create_environment(:name=>"env1", :label=> "env1", :organization => @organization, :prior => @organization.library)
        @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM,
                                     :organization => @organization, :repository_url => "https://something.url/stuff")
        @product = Product.new({:name=>"prod", :label=> "prod"})

        @product.provider = @provider
        @product.stubs(:arch).returns('noarch')
        @product.save!
        @repo_library = new_test_repo(@organization.library, @product, "repo", "#{@organization.name}/Library/prod/repo")
        @cv_library = @organization.library.content_views.first
        promote_content_view(@cv_library, @organization.library, @env1)
        ContentView.any_instance.stubs(:total_package_count).returns(0)
        ContentView.any_instance.stubs(:total_errata_count).returns(0)
        Repository.any_instance.stubs(:package_count).returns(0)
        Repository.any_instance.stubs(:errata_count).returns(0)
      end
      after do
        reset_search
      end
      [:packages, :errata, :puppet_modules].each do |content_type|
        [:all, :shared, :unique].each do |mode|
          context "#{content_type} #{mode} case" do
            before do
              @env1 = KTEnvironment.find(@env1.id)
              content_view = @env1.content_views.where(:id => @cv_library.id).first
              @repo = content_view.repos(@env1).first
              Repository.stubs(:search).returns([@repo])
              repo_filter_ids = [@repo_library.pulp_id, @repo.pulp_id].collect do |repo|
                {:term => {:repoids => [repo]}}
              end

              @expected_filters = { :all => {:or => repo_filter_ids},
                                    :shared => {:and => repo_filter_ids}}

              @expected_filters[:unique] ={:and => [@expected_filters[:all],
                                                    {:not =>{:filter => @expected_filters[:shared]}}]}
            end

            it "should return some #{content_type}" do
              setup_search(:filter => @expected_filters[mode],
                           :fields => [:id, :name, :nvrea, :repoids, :type, :errata_id, :author, :version],
                           :results => [])
              params = {"mode"=>mode.to_s, "#{content_type}"=>{"search"=>""}, "content_type"=>"#{content_type}", "repos"=>{"search"=>""}}
              post "#{content_type}", params
              must_respond_with(:success)
              result = JSON.parse(response.body)
              result["name"].must_equal content_type.to_s.split('_').map(&:capitalize).join(' ')
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
              view_id = @organization.default_content_view.id
              params = {"mode"=>mode.to_s, "type"=>"compare_#{content_type}", "repos"=>{
                "0"=>{"env_id"=>@repo_library.environment.id.to_s, "repo_id"=>@repo_library.id.to_s, "view_id"=>view_id},
                "1"=>{"env_id"=>@repo.environment.id.to_s, "repo_id"=>@repo.id.to_s, "view_id"=>view_id}}}
              post "repo_compare_#{content_type}", params
              must_respond_with(:success)
              result = JSON.parse(response.body)
              result["rows"].wont_be_empty
              result["rows"][0]["id"].must_equal result1.id
              result["cols"].wont_be_empty
              result["cols"][@repo_library.id.to_s].wont_be_nil
              result["cols"][@repo.id.to_s].wont_be_nil
            end
          end
        end
      end
    end
  end
end
