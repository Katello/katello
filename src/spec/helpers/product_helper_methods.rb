#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'helpers/repo_test_data'

module ProductHelperMethods

  def self.included(base)
    base.send :include, RepositoryHelperMethods
  end

  def new_test_product_with_library org
    @library = KTEnvironment.new
    @library.library = true
    @library.organization = org
    @library.name = "Library"
    @library.stub!(:products).and_return([])
    org.stub!(:library).and_return(@library)
    new_test_product org, @library
  end

  def new_test_product org, env, suffix="", custom=true
    disable_product_orchestration
    disable_repo_orchestration
    @provider = org.redhat_provider if !custom
    @provider ||= Provider.create!({:organization => org, :name => 'provider' + suffix, :repository_url => "https://something.url", :provider_type => Provider::CUSTOM})
    @p = Product.create!(ProductTestData::SIMPLE_PRODUCT.merge({:name=>'product' + suffix, :environments => [env],
                                                                :provider => @provider}))

    env_product = EnvironmentProduct.find_or_create(env, @p)


    repo = Repository.new(:environment_product => env_product, :name=>"FOOREPO" + suffix,
                          :label=>"FOOREPO" + suffix, :pulp_id=>RepoTestData::REPO_ID,
                          :content_id=> "1234", :content_view_version=>env.default_content_view_version,
                          :relative_path=>'/foo/', :feed => 'https://localhost.com/foo')
    repo.stub(:create_pulp_repo).and_return([])
    repo.save!

    pkg = Package.new(:name=>"Pkg" + suffix, :id=>"234" + suffix)
    repo.stub(:packages).and_return([pkg])

    errata = Errata.new(:title=>"Errata" + suffix, :id=>"1235" + suffix)
    repo.stub(:errata).and_return([errata])
    Glue::Pulp::Errata.stub!(:filter).and_return([:errata])
    distribution = Distribution.new()
    repo.stub(:distributions).and_return([distribution])

    @p.stub(:repos).and_return([repo])
    @p
  end

  def promote repo, environment
    disable_product_orchestration

    lib_instance = repo.library_instance.nil? ? repo : repo.library_instance

    ep_to_env = EnvironmentProduct.find_or_create(environment, repo.product)
    repo_clone = new_test_repo(ep_to_env, repo.name,
                               "#{environment.organization.name}/#{environment.name}/prod/repo", true, "", lib_instance)
    repo.stub(:create_clone).and_return(repo_clone)
    repo.stub(:clone_contents).and_return([])
    repo.stub(:sync).and_return([])

    repo.stub!(:pulp_repo_facts).and_return({:clone_ids => []})
    repo.stub(:content => {:id => "123"})
    repo.promote(environment.prior, environment)
    ep = EnvironmentProduct.find_or_create(environment, repo.product)
    Repository.where(:environment_product_id => ep).first.tap do |promoted|
        promoted.stub(:feed => repo.feed)
    end
  end
end
