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

class EnvironmentProduct < ActiveRecord::Base
  belongs_to :product, :inverse_of => :environment_products
  belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :environment_products
  has_many :repositories, :dependent => :destroy, :inverse_of => :environment_product

  def self.find_or_create(env, product)
    item = EnvironmentProduct.where(:environment_id=> env.id, :product_id=> product.id).first
    item ||= EnvironmentProduct.create!(:environment=> env, :product=> product)
    item
  end
end
