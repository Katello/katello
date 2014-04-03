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
  module Authorization
    module Product
      extend ActiveSupport::Concern

      included do
        scope :readable, lambda{|org| all_readable(org).with_enabled_repos_only(org.library)}
        scope :editable, lambda {|org| all_editable(org).with_enabled_repos_only(org.library)}
        scope :syncable, lambda {|org| sync_items(org).with_enabled_repos_only(org.library)}

        def readable?
          Katello::Product.all_readable(self.organization).where(:id => id).count > 0
        end

        def syncable?
          Katello::Product.syncable(self.organization).where(:id => id).count > 0
        end

        def editable?
          self.provider.editable?
        end

        def deletable?
          promoted_repos = repositories.select { |repo| repo.promoted? }
          editable? && promoted_repos.empty?
        end

      end # included

      module ClassMethods
        # scope
        def with_repos_only(env)
          with_repos(env, false)
        end

        # scope
        def with_enabled_repos_only(env)
          with_repos(env, true)
        end

        def all_readable_in_library(org)
          all_readable(org).with_repos_only(org.library)
        end

        def all_readable(org)
          Katello::Product.where(:provider_id => Katello::Provider.readable(org).pluck(:id))
        end

        def all_editable(org)
          Katello::Product.where(:provider_id => Katello::Provider.editable(org).where(:provider_type => Katello::Provider::CUSTOM).pluck(:id))
        end

        def assert_deletable(products)
          invalid_perms = products.select{ |product| !product.deletable? }.collect{ |product| product.name }

          unless invalid_perms.empty?
            fail Errors::SecurityViolation, _("Product deletion is not allowed for product(s): %s") % invalid_perms.join(', ')
          end
          true
        end

        def assert_syncable(products)
          invalid_perms = products.select{ |product| !product.syncable? }.collect{ |product| product.name }

          unless invalid_perms.empty?
            fail Errors::SecurityViolation, _("Product syncing is not allowed for product(s): %s") % invalid_perms.join(', ')
          end
          true
        end

        def assert_editable(products)
          invalid_perms = products.select{ |product| !product.editable? }.collect{ |product| product.name }

          unless invalid_perms.empty?
            fail Errors::SecurityViolation, _("Product modification is not allowed for product(s): %s") % invalid_perms.join(', ')
          end
          true
        end

        def creatable?(provider)
          provider.editable?
        end

        def any_readable?(org)
          Katello::Provider.any_readable?(org)
        end

        def sync_items(org)
          org.syncable? ? (joins(:provider).where("#{Katello::Provider.table_name}.organization_id" => org)) : where("0=1")
        end

        def with_repos(env, enabled_only)
          query = Katello::Repository.in_environment(env.id).select(:product_id)
          query = query.enabled if enabled_only
          joins(:provider).where("#{Katello::Provider.table_name}.organization_id" => env.organization).
              where("(#{Katello::Provider.table_name}.provider_type ='#{Katello::Provider::CUSTOM}') OR \
                    (#{Katello::Provider.table_name}.provider_type ='#{Katello::Provider::ANONYMOUS}') OR \
                    (#{Katello::Provider.table_name}.provider_type ='#{Katello::Provider::REDHAT}' AND \
                    #{Katello::Product.table_name}.id in (#{query.to_sql}))")
        end

      end # ClassMethods

    end # Product
  end # Authorization
end # Katello
