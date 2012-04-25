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

class PgCategoryValidator < ActiveModel::Validator
  def validate(record)
    env = record.system_template.environment
    if env.package_group_categories({'name' => record.name}).length == 0
      record.errors[:base] <<  _("Package group category '%s' not found in the %s environment") % [record.name, env.name]
    end
  end
end

class SystemTemplatePgCategory < ActiveRecord::Base
  belongs_to :system_template, :inverse_of => :pg_categories
  validates_with PgCategoryValidator
  validates_uniqueness_of [:name], :scope =>  :system_template_id, :message => _("is already in the template")

end
