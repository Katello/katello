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

module Katello
class ContentViewVersion < Katello::Model
  self.include_root_in_json = false

  include AsyncOrchestration
  include Authorization::ContentViewVersion

  belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :content_view_versions
  has_many :content_view_version_environments, :class_name => "Katello::ContentViewVersionEnvironment",
           :dependent => :destroy
  has_many :environments, :through      => :content_view_version_environments,
                          :class_name   => "Katello::KTEnvironment",
                          :inverse_of   => :content_view_versions,
                          :before_add    => :add_environment,
                          :after_remove => :remove_environment

  has_many :repositories, :class_name => "Katello::Repository", :dependent => :destroy
  has_one :task_status, :class_name => "Katello::TaskStatus", :as => :task_owner, :dependent => :destroy

  scope :default_view, joins(:content_view).where("#{Katello::ContentView.table_name}.default" => true)
  scope :non_default_view, joins(:content_view).where("#{Katello::ContentView.table_name}.default" => false)

  def to_s
    "#{content_view} #{version}"
  end

  def has_default_content_view?
    ContentViewVersion.default_view.pluck("#{Katello::ContentViewVersion.table_name}.id").include?(self.id)
  end

  def repos(env)
    self.repositories.in_environment(env)
  end

  def products(env = nil)
    if env
      repos(env).map(&:product).uniq(&:id)
    else
      self.repositories.map(&:product).uniq(&:id)
    end
  end

  def repos_ordered_by_product(env)
    # The repository model has a default scope that orders repositories by name;
    # however, for content views, it is desirable to order the repositories
    # based on the name of the product the repository is part of.
    Repository.send(:with_exclusive_scope) do
      self.repositories.joins(:product).in_environment(env).order("#{Katello::Product.table_name}.name asc")
    end
  end

  def get_repo_clone(env, repo)
    lib_id = repo.library_instance_id || repo.id
    self.repos(env).where("#{Katello::Repository.table_name}.library_instance_id" => lib_id)
  end

  def self.in_environment(env)
    joins(:content_view_version_environments).where("#{Katello::ContentViewVersionEnvironment.table_name}.environment_id" => env).
        order("#{Katello::ContentViewVersionEnvironment.table_name}.environment_id")
  end

  def deletable?(from_env)
    !System.exists?(:environment_id => from_env, :content_view_id => self.content_view) ||
        self.content_view.versions.in_environment(from_env).count > 1
  end

  def delete(from_env)
    unless deletable?(from_env)
      fail Errors::ChangesetContentException.new(_("Cannot delete view %{view} from %{env}, systems are currently subscribed. " +
                                                    "Please move subscribed systems to another content view or environment.") %
                                                    {:env => from_env.name, :view => self.content_view.name})
    end

    self.environments.delete(from_env)
    self.repositories.in_environment(from_env).each{|r| r.destroy}
    if self.environments.empty?
      self.destroy
    else
      self.save!
    end
  end

  def trigger_repository_changes
    Repository.trigger_contents_changed(self.repositories, :wait => true, :reindex => true)
  end

  private

  def add_environment(env)
    content_view.add_environment(env) if content_view.content_view_versions.in_environment(env).count == 0
  end

  def remove_environment(env)
    content_view.remove_environment(env)  unless content_view.content_view_versions.in_environment(env).count > 1
  end

end
end
