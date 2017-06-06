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


module Glue::ElasticSearch::Changeset
  def self.included(base)
    base.send :include, Ext::IndexedModel

    base.class_eval do

      index_options :extended_json => :extended_index_attrs,
                    :display_attrs => [:name, :description, :package, :errata, :product, :repo, :user, :type]

      mapping do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
      end


    end
  end

  def extended_index_attrs
    type      = self.type == "PromotionChangeset" ? Changeset::PROMOTION : Changeset::DELETION
    pkgs      = self.packages.collect { |pkg| pkg.display_name }
    errata    = self.errata.collect { |err| err.display_name }
    products  = self.products.collect { |prod| prod.name }
    repos     = self.repos.collect { |repo| repo.name }
    { :name_sort       => self.name.downcase,
      :type            => type,
      :package         => pkgs,
      :errata          => errata,
      :product         => products,
      :repo            => repos,
      :user            => self.task_status.nil? ? "" : self.task_status.user.username
    }
  end

end
