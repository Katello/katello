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

  after_save :update_related_index

  belongs_to :environment_product, :inverse_of => :repositories
  has_and_belongs_to_many :changesets
  validates :pulp_id, :presence => true, :uniqueness => true
  validates :name, :presence => true
  validates :enabled, :repo_disablement => true, :on => [:update]
  belongs_to :gpg_key, :inverse_of => :repositories

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

  scope :enabled, where(:enabled => true)

  scope :readable, lambda { |env|
    if env.contents_readable?
      joins(:environment_product).where("environment_products.environment_id" => env.id)
    else
      #none readable
      where("1=0")
    end
  }

  scope :readable_in_org, lambda {|org, *skip_library|
    if (skip_library.empty? || skip_library.first.nil?)
      # 'skip library' not included, so retrieve repos in library in the result
      joins(:environment_product).where("environment_products.environment_id" =>  KTEnvironment.content_readable(org))
    else
      joins(:environment_product).where("environment_products.environment_id" =>  KTEnvironment.content_readable(org).where(:library => false))
    end
  }

  def self.any_readable_in_org? org, skip_library = false
    KTEnvironment.any_contents_readable? org, skip_library
  end


  def extended_index_attrs
    {:environment=>self.environment.name, :environment_id=>self.environment.id,
     :product=>self.product.name, :product_id=> self.product.id}
  end

  def update_related_index
    self.product.provider.update_index if self.product.provider.respond_to? :update_index
  end

  def index_packages
    pkgs = self.packages.collect{|pkg| pkg.as_json.merge(pkg.index_options)}
    Tire.index Glue::Pulp::Package.index do
      create :settings => Glue::Pulp::Package.index_settings, :mappings => Glue::Pulp::Package.index_mapping
      import pkgs
    end if !pkgs.empty?
  end

  def index_errata
    errata = self.errata.collect{|err| err.as_json.merge(err.index_options)}
    Tire.index Glue::Pulp::Errata.index do
      create :settings => Glue::Pulp::Errata.index_settings, :mappings => Glue::Pulp::Errata.index_mapping
      import errata
    end if !errata.empty?
  end

  def gpg_key_name=(name)
    if name.blank?
      self.gpg_key = nil
    else
      self.gpg_key = GpgKey.readable(organization).find_by_name!(name)
    end
  end

  def as_json(*args)
    ret = super
    ret["gpg_key_name"] = gpg_key ? gpg_key.name : ""
    ret["package_count"] = package_count rescue nil
    ret
  end

  protected

end
