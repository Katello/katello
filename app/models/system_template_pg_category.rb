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
    repo = Glue::Pulp::Repo.new(:id => record.repo_id)
    unless repo.package_group_categories(:id => record.pg_category_id).first
      record.errors[:base] <<  (_("Package group category '%s' doesn't exist in repo '%s'") % [record.pg_category_id, record.repo_id])
    end
  end
end

class SystemTemplatePgCategory < ActiveRecord::Base
  belongs_to :system_template, :inverse_of => :pg_categories
  validates_with PgCategoryValidator
  validates_uniqueness_of [:pg_category_id], :scope =>  [:system_template_id, :repo_id], :message => _("is already in the template")

  def export_hash
    {:id => self.pg_category_id, :repo => self.repo_id}
  end
end
