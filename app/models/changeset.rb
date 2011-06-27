#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Changeset < ActiveRecord::Base
  include Authorization
  before_validation(:generate_name, :on=>:create)

  NEW = 'new'
  REVIEW = 'review'
  PROMOTED = 'promoted'
  STATES = [NEW, REVIEW, PROMOTED]

  validates_inclusion_of :state,
    :in => STATES,
    :allow_blank => false,
    :message => "A changeset must have one of the following states: #{STATES.join(', ')}."


  validates :name, :presence => true, :allow_blank => false
  validates_uniqueness_of :name, :scope => :environment_id, :message => N_("Must be unique within an environment") 
  has_and_belongs_to_many :products, :uniq => true
  has_many :packages, :class_name=>"ChangesetPackage", :inverse_of=>:changeset
  has_many :users, :class_name=>"ChangesetUser", :inverse_of=>:changeset
  has_many :errata, :class_name=>"ChangesetErratum", :inverse_of=>:changeset
  has_many :repos, :class_name=>"ChangesetRepo", :inverse_of => :changeset
  belongs_to :environment, :class_name=>"KPEnvironment"
  validates :environment, :presence=>true
  before_save :uniquify_artifacts



  def generate_name
    #self.name = I18n.l(DateTime.now, :format=>:long) if name.blank?
    self.name = "XXX" if name.blank?
  end


  def key_for item
    "changeset_#{id}_#{item}"
  end

  def package_ids
    packages.collect{|pack| pack.package_id}
  end

  def errata_ids
    errata.collect{|erratum| erratum.errata_id}
  end

  #get a list of all the products involved in teh changeset
  #  but not necessarily 'in' the changeset
  def involved_products
    to_ret = self.products.clone #get a copy
    to_ret =  to_ret + self.packages.collect{|pkg| pkg.product}
    to_ret =  to_ret + self.errata.collect{|pkg| pkg.product}
    to_ret =  to_ret + self.repos.collect{|pkg| pkg.product}
    to_ret.uniq
  end


  def dependencies
    from_env = self.environment
    to_env   = self.environment.successor

    repoids = []

    #get source repos to depsolve for
    from_env.products.each{|prod|
      repoids += prod.repos(from_env).collect{|repo| repo.id}
    }

    #TODO  look up NEVRA from pulp instead of relying on display_name
    #   will this be too expensive?  should display_name be "formalized"
    changelog_pkgs = self.packages.collect{|pkg| pkg.display_name}


    #pulp can't handle an empty package list
    return [] if changelog_pkgs.empty?

    all_pkgs = Pulp::Package.dep_solve(changelog_pkgs, repoids).collect do |package|
         Glue::Pulp::Package.new(package)
    end

    #remove pkgs that are in the target environment's repos
    repo_pkg_ids = []
    to_env.products do |prod|
      prod.repos to_env do |repo|
        repo_pkg_ids += repo.packages.collect{|pkg| pkg.id}
      end
    end

    uniq_pkgs = []
    all_pkgs.each {|pkg|
      uniq_pkgs << pkg if repo_pkg_ids.index(pkg.id).nil?
    }

    uniq_pkgs

  end

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def promote
    from_env = self.environment
    to_env   = self.environment.successor

    promote_products from_env, to_env
    promote_repos    from_env, to_env
    promote_packages from_env, to_env
    promote_errata   from_env, to_env

    self.promotion_date = Time.now
    self.state = Changeset::PROMOTED
    self.save!
  end

  private

  def promote_products from_env, to_env
    #promote all products stacked for promotion
    self.products.each do |product|
      product.promote from_env, to_env
    end
  end

  def promote_repos from_env, to_env

    #promote only repos that haven't already been promoted with products
    for_not_promoted_products from_env do |product|

      #get repos that should be promoted and belong to this product
      #{all repos stacked for promotion} AND {repos in this product and env}
      repo_ids_to_promote = self.repos.map(&:repo_id) & product.repos(from_env).map(&:id)

      repo_ids_to_promote.each do |repo_id|
        #check if product with the repo has been promoted (= repo cloned)
        #if yes then sync the promoted repo
        repo = Glue::Pulp::Repo.find(repo_id)
        if product.is_cloned_in?(repo, to_env)
          repo.sync
        end
      end
    end

  end

  def promote_packages from_env, to_env
    #repo->list of pkg_ids
    pkgs_promote = {}

    #promote only packages that haven't already been promoted with products
    for_not_promoted_repos from_env do |repo, clones|

      self.packages.each do |pkg|
        #if this repo has the package and the clone doesn't, then we should promote it
        if repo.has_package? pkg.package_id
          clones.each do |clone|
            if !clone.has_package? pkg.package_id
              pkgs_promote[clone] ||= []
              pkgs_promote[clone] << pkg.package_id
            end
          end
        end
      end
    end

    pkgs_promote.each_pair do |repo, pkgs|
      repo.add_packages(pkgs)
    end
  end


  def promote_errata from_env, to_env
    #repo->list of errata_ids
    errata_promote = {}

    #promote only errata that haven't already been promoted with products
    for_not_promoted_repos from_env do |repo, clones|

      self.errata.each do |err|
        #if this repo has the package and the clone doesn't, then we should promote it
        if repo.has_erratum? err.errata_id
          clones.each do |clone|
            if !clone.has_erratum? err.errata_id
              errata_promote[clone] ||= []
              errata_promote[clone] << err.errata_id
            end
          end
        end
      end
    end

    errata_promote.each_pair do |repo, errata|
      repo.add_errata(errata)
    end
  end

  def for_not_promoted_products from_env, &block
    #executes block for every product not stacked for promotion

    from_env.products.each do |product|
      next if self.products.include?(product)
      yield product
    end
  end

  def for_not_promoted_repos from_env, &block
    #executes block for all repos from products not stacked for promotion

    for_not_promoted_products from_env do |product|
      product.repos(from_env).each do |repo|
        #get clones of the repo
        clones = repo.clone_ids.collect do |id|
          Glue::Pulp::Repo.find(id)
        end

        yield repo, clones
      end
    end
  end

  def uniquify_artifacts
    self.products.uniq! unless self.products.nil?
    [[:packages,:package_id],[:errata, :errata_id],[:repos, :repo_id]].each do |items, item_id|
      unless self.send(items).nil?
        s = Set.new
        # for some reason uniq! with a closure didn''t work
        # so invented an equivalent
        self.send(items).reject! do |item|
          includes = s.include? item.send(item_id)
          s.add(item.send(item_id)) unless includes
          includes
        end
      end
    end
  end

end
