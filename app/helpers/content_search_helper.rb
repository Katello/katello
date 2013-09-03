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

module ContentSearchHelper

  def content_types
    [
      [_("Content Views"), "views"],
      [_("Products"), "products"],
      [_("Repositories"), "repos"],
      [_("Packages"), "packages"],
      [_("Errata"), "errata"],
      [_("Puppet Modules"), "puppet_modules"]
    ]
  end

  def errata_display(errata)
    {
      :errata_type => errata[:type],
      :id => errata.id,
      :errata_id => errata.errata_id
    }
  end

  def package_display(package)
    {
      :name => package.name,
      :vel_rel_arch => package.send(:nvrea).sub(package.send(:name) + '-', ''),
      :id => package.id
    }
  end

  def puppet_module_display(puppet_module)
    {
      :name_version => [puppet_module.name, puppet_module.version].join('-'),
      :author => puppet_module.author,
      :id => puppet_module.id
    }
  end

  def repo_compare_name_display(repo)
    {
      :environment_name => repo.environment.name,
      :repo_name => repo.name,
      :content_view_name => repo.content_view.name,
      :type => "repo-comparison",
      :custom => true
    }
  end

end
