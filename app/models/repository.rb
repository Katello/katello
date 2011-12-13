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

class RepoDisablementValidator < ActiveModel::Validator
  def validate(record)
    if record.redhat? && record.enabled_changed? && (!record.enabled?) && record.promoted?
      record.errors[:base] << N_("Repository cannot be disabled since it has already been promoted.")
    end
  end
end


class Repository < ActiveRecord::Base
  include Glue::Pulp::Repo if (AppConfig.use_cp and AppConfig.use_pulp)
  include Glue if AppConfig.use_cp
  include Authorization
  include AsyncOrchestration
  include IndexedModel
  
  index_options :extended_json=>:extended_index_attrs,
                :json=>{:except=>[:pulp_repo_facts, :groupid, :environment_product_id]}


  belongs_to :environment_product, :inverse_of => :repositories
  has_and_belongs_to_many :changesets
  validates :pulp_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  validates :enabled, :repo_disablement => true, :on => [:update]
  belongs_to :gpg_key, :inverse_of => :repositories

  before_validation :setup_repo_gpg, :on =>[:create]

  def product
    self.environment_product.product
  end

  def environment
    self.environment_product.environment
  end

  def organization
    self.environment.organization
  end

  #temporary major version
  def major_version
    return nil if release.nil?
    release.to_i
  end

  def redhat?
    product.redhat?
  end

  def custom?
    !(redhat?)
  end

  def extended_index_attrs
    {:environment=>self.environment.name, :environment_id=>self.environment.id,
     :product=>self.product.name, :product_id=> self.product.id}
  end


  def index_packages
    pkgs = self.packages.collect{|pkg| pkg.as_json.merge({:_type =>'package'})}
    Tire.index AppConfig.elastic_index do
      import pkgs               
    end
  end

  def index_errata
    errata = self.errata.collect{|err| err.as_json.merge({:_type =>'errata'})}
    Tire.index AppConfig.elastic_index do
      import errata
    end
  end

  protected
  def setup_repo_gpg
    unless gpg_key
      self.gpg_key = product.gpg_key
    end
  end



end
