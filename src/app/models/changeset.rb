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
  before_create :generate_name

  NEW = 'new'
  REVIEW = 'review'
  PROMOTED = 'promoted'
  STATES = [NEW, REVIEW, PROMOTED]

  validates_inclusion_of :state,
    :in => STATES,
    :allow_blank => false,
    :message => "A changeset must have one of the following states: #{STATES.join(', ')}."

  validates :name, :presence => true, :katello_name_format => true, :allow_blank => false
  validates_uniqueness_of :name, :scope => :environment_id, :message => N_("Must be unique within an environment")
  has_and_belongs_to_many :products
  has_many :packages, :class_name=>"ChangesetPackage", :inverse_of=>:changeset
  has_many :users, :class_name=>"ChangesetUser", :inverse_of=>:changeset
  has_many :errata, :class_name=>"ChangesetErratum", :inverse_of=>:changeset
  has_many :repos, :class_name=>"ChangesetRepo", :inverse_of => :changeset
  belongs_to :environment, :class_name=>"KPEnvironment"
  before_save :uniquify_artifacts



  def generate_name
    self.name = I18n.l(DateTime.now, :format=>:long) if name.blank?
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


  def dependencies
    repoids = []

    prior = self.environment.prior
    prior ||= self.environment.organization.locker #if no prior, then prior must be locker

    #get source repos to depsolve for
    prior.products.each{|prod|
      repoids += prod.repos(prior).collect{|repo| repo.id}
    }

    #TODO  look up NEVRA from pulp instead of relying on display_name
    #   will this be too expensive?  should display_name be "formalized"
    changelog_pkgs = self.packages.collect{|pkg| pkg.display_name}


    #pulp can't handle an empty package list
    return [] if changelog_pkgs.empty?

    all_pkgs = Pulp::Package.dep_solve(changelog_pkgs, repoids).collect do |package|
         Glue::Pulp::Package.new(package)
    end

    #remove pkgs that are in the next environment's repos
    repo_pkg_ids = []
    if environment
      environment.products do |prod|
        prod.repos do |repo|
          repo_pkg_ids += repo.packages.collect{|pkg| pkg.id}
        end
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
    self.products.each do |product|
      product.promote self,  self.environment
    end

    #repo->list of pkg_ids
    pkgs_promote = {}


    #Identify which repos need what packages
    #self.environment.products.each do |product|
      #skip the product if we are promoting it anyways
    #  next if self.products.include?(product)
    #  product.repos(self).each do |repo|
        #bring in the clones, for caching
    #    clones = []
    #    repo.clone_ids.each{|id|  clones << Glue::Pulp::Repo.find(id)}

    #    self.packages.each do |pkg|
          #if this repo has the package and the clone doesn't, then we should promote it
    #       if repo.has_package? pkg.package_id
    #         clones.each do |clone|
    #           if !clone.has_package? pkg.package_id
    #             pkgs_promote[clone] ||= []
    #             pkgs_promote[clone] << pkg.package_id
    #           end
    #         end
    #       end
    #     end
    #   end
    # end

    #pkgs_promote.each_pair do |repo, pkgs|
    #  repo.add_packages(pkgs)
    #end

    self.promotion_date = Time.now
    self.state = Changeset::PROMOTED
    self.save!

  end

  private
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
