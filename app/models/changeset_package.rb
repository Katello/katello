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
    record.errors[:base] << _("Package '%s' doesn't belong to the specified product!") %
        record.package_id and return if record.repositories.empty?
    record.errors[:base] << _("Repository of the package '%s' has not been promoted into the target environment!") %
        record.package_id if record.promotable_repositories.empty?
  end
end

class ChangesetPackage < ActiveRecord::Base
  include Authorization

  belongs_to :changeset, :inverse_of => :packages
  belongs_to :product
  validates :display_name, :length => { :maximum => 255 }
  validates :nvrea, :presence => true, :uniqueness => { :scope => :changeset_id }
  validates_with ChangesetPackageValidator

  def repositories
    return @repos if not @repos.nil?

    from_env = self.changeset.environment.prior
    @repos   = []

    self.product.repos(from_env).each do |repo|
      @repos << repo if repo.has_package? self.package_id
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

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,display_name').all.collect { |m| VirtualTag.new(m.id, m.display_name) }
  end

end
