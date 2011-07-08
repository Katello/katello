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

class ActivationKey < ActiveRecord::Base

  scoped_search :on => :name, :complete_value => true, :default_order => true, :rename => :'key.name'
  scoped_search :on => :description, :complete_value => true, :rename => :'key.description'

  validates :name, :uniqueness => true, :presence => true, :katello_name_format => true
  validates :description, :katello_description_format => true

end
