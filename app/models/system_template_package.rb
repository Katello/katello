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

class PackageValidator < ActiveModel::Validator
  def validate(record)
    if record.to_package.nil?
      record.errors[:base] <<  _("Package '#{record.package_name}' has doesn't belong to any product in this template")
    end
  end
end

class SystemTemplatePackage < ActiveRecord::Base
  include Authorization

  belongs_to :system_template, :inverse_of => :packages
  validates_uniqueness_of :package_name, :scope =>  :system_template_id
  validates_with PackageValidator

  def to_package
    self.system_template.environment.products.each do |product|
       product.repos(self.system_template.environment).each do |repo|
        #search for errata in all repos in a product
        idx = repo.packages.index do |p| p.name == self.package_name end
        return repo.packages[idx] if idx != nil

      end
    end
    nil
  end


end
