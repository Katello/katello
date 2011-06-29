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

class ErratumValidator < ActiveModel::Validator
  def validate(record)
    if record.to_erratum.nil?
      record.errors[:base] <<  _("Erratum '#{record.erratum_id}' has doesn't belong to any product in this template")
    end
  end
end

class SystemTemplateErratum < ActiveRecord::Base
  include Authorization

  belongs_to :system_template, :inverse_of => :errata
  validates_uniqueness_of :erratum_id, :scope =>  :system_template_id
  validates_with ErratumValidator

  def to_erratum
    self.system_template.products.each do |product|
      product.repos(self.system_template.environment).each do |repo|
        #search for errata in all repos in a product
        idx = repo.errata.index do |e| e.id == self.erratum_id end
        return repo.errata[idx] if idx != nil

      end
    end
    nil
  end

end
