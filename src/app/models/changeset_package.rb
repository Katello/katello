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

class ChangesetPackageValidator < ActiveModel::Validator
  def validate(record)
    from_env = record.changeset.environment.prior
    to_env   = record.changeset.environment
    product = Product.find(record.product_id)

    #package must be in one of the repositories in the source environment
    #the repository must belong to a product that is in both source and target environment

    if not (product.environments.include? from_env and product.environments.include? to_env)
      record.errors[:base] <<  _("Product of the package '#{record.package_id}' must belong to both source and target environment!")
    end

    product.repos(from_env).each do |repo|
      #search for the package in all repos in its product
      return if repo.has_package? record.package_id
    end

    record.errors[:base] <<  _("Package '#{record.package_id}' doesn't belong to the specified product!")
  end
end

class ChangesetPackage < ActiveRecord::Base
  include Authorization

  belongs_to :changeset, :inverse_of=>:packages
  belongs_to :product
  validates_with ChangesetPackageValidator

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,display_name').all.collect { |m| VirtualTag.new(m.id, m.display_name) }
  end
end
