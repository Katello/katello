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
#

class ChangesetDistribution < ActiveRecord::Base

  belongs_to :changeset, :inverse_of => :distributions
  belongs_to :product
  validates :distribution_id, :uniqueness => { :scope => [:changeset_id, :product_id] }
  validates_with Validators::ChangesetDistributionValidator

  def repositories
    return @repos if not @repos.nil?

    from_env = self.changeset.environment.prior
    @repos   = []

    self.product.repos(from_env).each do |repo|
      @repos << repo if repo.has_distribution? self.distribution_id
    end
    @repos
  end

  def promotable_repositories
    to_env = self.changeset.environment

    repos = []
    self.repositories.each do |repo|
      repos << repo if repo.is_cloned_in? to_env
    end
    repos
  end

end
