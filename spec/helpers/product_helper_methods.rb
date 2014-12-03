#
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

require File.expand_path("repo_test_data", File.dirname(__FILE__))
require File.expand_path("product_test_data", File.dirname(__FILE__))

module Katello
  module ProductHelperMethods
    def self.included(base)
      base.send :include, RepositoryHelperMethods
    end

    def new_test_product_with_library(org)
      @library = KTEnvironment.new
      @library.library = true
      @library.organization = org
      @library.name = "Library"
      @library.stubs(:products).returns([])
      org.stubs(:library).returns(@library)
      new_test_product org, @library
    end

    def new_test_product(org, env, suffix = "", custom = true)
      disable_product_orchestration
      disable_repo_orchestration
      @provider = org.redhat_provider unless custom
      @provider ||= Provider.create!(:organization => org, :name => 'provider' + suffix, :repository_url => "https://something.url", :provider_type => Provider::CUSTOM)
      product_attributes = ProductTestData::SIMPLE_PRODUCT.merge(:name => 'product' + suffix, :provider => @provider)
      product_attributes[:productContent] = []
      @p = Product.create!(product_attributes)

      repo = Repository.new(:environment => env, :product => @p, :name => "FOOREPO" + suffix,
                            :label => "FOOREPO" + suffix, :pulp_id => RepoTestData::REPO_ID,
                            :content_id => "1234", :content_view_version => env.default_content_view_version,
                            :relative_path => '/foo/', :url => 'https://localhost.com/foo')
      repo.stubs(:create_pulp_repo).returns([])
      repo.save!

      pkg = Package.new(:name => "Pkg" + suffix, :id => "234" + suffix)
      repo.stubs(:packages).returns([pkg])

      errata = Errata.new(:title => "Errata" + suffix, :id => "1235" + suffix)
      repo.stubs(:errata).returns([errata])
      Glue::Pulp::Errata.stubs(:filter).returns([:errata])
      distribution = Distribution.new
      repo.stubs(:distributions).returns([distribution])

      @p.stubs(:repos).returns([repo])
      @p
    end

    def promote(repo, environment)
      disable_product_orchestration

      lib_instance = repo.library_instance.nil? ? repo : repo.library_instance

      repo_clone = new_test_repo(environment, repo.product, repo.name,
                                 "#{environment.organization.name}/#{environment.name}/prod/repo", "", lib_instance)
      repo.stubs(:create_clone).returns(repo_clone)
      repo.stubs(:clone_contents).returns([])
      repo.stubs(:sync).returns([])

      repo.stubs(:pulp_repo_facts).returns('distributors' => [])
      repo.stubs(:content => {:id => "123"})
      Repository.where(:environment_id => environment, :product_id => repo.product).first.tap do |promoted|
        promoted.stubs(:url => repo.url)
      end
    end
  end
end
