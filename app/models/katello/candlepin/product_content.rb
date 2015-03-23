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
  class Candlepin::ProductContent
    include ForemanTasks::Triggers

    attr_accessor :content, :enabled, :product

    def initialize(params = {}, product_id = nil)
      params = params.with_indifferent_access
      #controls whether repo is enabled in yum repo file on client
      #  unrelated to enable/disable from katello
      @enabled = params[:enabled]
      @content = Candlepin::Content.new(params[:content])
      @product_id = product_id
    end

    def create
      @content.create
    end

    def destroy
      @content.destroy
    end

    def product
      @product ||= Product.find(@product_id) if @product_id
      @product
    end

    def repositories
      @repos ||= self.product.repos(self.product.organization.library).where(:content_id => self.content.id)
    end

    def content_override(activation_key)
      override = activation_key.content_overrides.find { |pc| pc[:contentLabel] == content.label }
      override.nil? ? 'default' : override[:value]
    end
  end
end
