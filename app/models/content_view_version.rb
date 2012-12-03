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


class ContentViewVersion < ActiveRecord::Base

  belongs_to :content_view
  has_many :content_view_version_environments
  has_many :environments, :through=>:content_view_version_environments,
           :class_name=>"KTEnvironment", :inverse_of=>:content_view_versions

  has_many :repositories, :dependent => :destroy

  scope :default_view, joins(:content_view).where('content_views.default = ?', true)
  scope :non_default_view, joins(:content_view).where('content_views.default = ?', false)

  def repos(env)
    self.repositories.in_environment(env)
  end

  def repos_ordered_by_product(env)
    # The repository model has a default scope that orders repositories by name;
    # however, for content views, it is desirable to order the repositories
    # based on the name of the product the repository is part of.
    Repository.send(:with_exclusive_scope) {self.repositories.joins(:environment_product => :product).
        in_environment(env).order('products.name asc')}
  end

  def self.in_environment(env)
    joins(:content_view_version_environments).where('content_view_version_environments.environment_id'=>env.id)
  end

  def delete(from_env)
    self.environments.delete(from_env)
    self.repositories.in_environment(from_env).each{|r| r.destroy}
    if self.environments.empty?
      self.destroy
    else
      self.save!
    end
  end

end
