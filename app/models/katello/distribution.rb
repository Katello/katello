#
# Copyright 2014 Red Hat, Inc.
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
class Distribution
  include Glue::Pulp::Distribution if Katello.config.use_pulp
  include Glue::ElasticSearch::Distribution if Katello.config.use_elasticsearch
  CONTENT_TYPE = "distribution"

  def bootable?
    # Not every distribution from Pulp represents a bootable
    # repo. Determine based on the files in the repo.
    self.files.any? do |file|
      if file.is_a? Hash
        filename = file[:relativepath]
      else
        filename = file
      end
      filename.include?("vmlinuz") || filename.include?("pxeboot")
    end
  end
end
end
