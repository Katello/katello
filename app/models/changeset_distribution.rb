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
#

class ChangesetDistributionValidator < ActiveModel::Validator
  def validate(record)
    from_env = record.changeset.environment.prior
    to_env = record.changeset.environment
    product = Product.find(record.product_id)

    record.errors[:base] <<  _("Distribution '#{record.distribution_id}' does not belong to the specified product!") and return if record.repositories.empty?

    record.repositories.each do |repo|
      record.errors[:base] <<  _("Distribution's repository must be promoted first!") and return if not repo.is_cloned_in? to_env
    end
  end
end

class ChangesetDistribution < ActiveRecord::Base

  belongs_to :changeset, :inverse_of=>:distributions
  belongs_to :product
  validates_with ChangesetDistributionValidator

  def repositories
    return @repos if not @repos.nil?

    from_env = self.changeset.environment.prior
    @repos = []

    self.product.repos(from_env).each do |repo|
      @repos << repo if repo.has_distribution? self.distribution_id
    end
    @repos
  end

end
