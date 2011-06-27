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

class TemplateErratum < ActiveRecord::Base
  include Authorization

  belongs_to :system_template, :inverse_of => :errata

  def to_erratum
    self.system_template.products.each do |product|
      product.repos(self.system_template.environment).each do |repo|
        #search for errata in all repos in a product
        idx = repo.errata.index do |e| e.id == erratum_id end
        return repo.errata[idx] if idx != nil

      end
    end
    nil
  end

  # returns list of virtual permission tags for the current user
  #def self.list_tags
  #  select('id,display_name').all.collect { |m| VirtualTag.new(m.id, m.display_name) }
  #end
end
