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

class ChangesetsSystemTemplate < ActiveRecord::Migration
  def self.up
    create_table :changesets_system_templates, :id => false do |t|
       t.references :changeset, :null=>false
       t.references :system_template, :null=>false
    end

  end

  def self.down
    drop_table :changesets_system_templates
  end
end
