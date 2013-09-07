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

module Glue::ElasticSearch::Provider
  def self.included(base)
    base.send :include, Ext::IndexedModel

    base.class_eval do
      index_options :extended_json=>:extended_index_attrs,
                    :display_attrs=>[:name, :product, :repo, :description]

      mapping do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
        indexes :provider_type, :type => 'string', :index => :not_analyzed
      end
    end
  end

  def extended_index_attrs
    if Katello.config.katello?
      products = self.products.map do |prod|
        {:product=>prod.name, :repo=>prod.repos(self.organization.library).collect{|repo| repo.name}}
      end
    else
      products = self.products.map{|prod| {:product => prod.name} }
    end
    {
      :products=>products,
      :name_sort=>name.downcase
    }
  end

end
