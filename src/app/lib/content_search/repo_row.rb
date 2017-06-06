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

class ContentSearch::RepoRow < ContentSearch::Row
  attr_accessor :repo

  def initialize(options)
    super
    build_row
  end

  def build_row
    self.data_type ||= "repo"
    self.cols ||= {}
    self.id ||= build_id
    self.name ||= @repo.name
  end

  def build_id
    [parent_id, data_type, repo.id].select(&:present?).join("_")
  end
end
