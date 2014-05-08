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
module Authorization::Repository
  extend ActiveSupport::Concern

  included do

    def readable?
      product.readable?
    end

    def editable?
      product.editable?
    end

    def deletable?
      product.editable? && !promoted?
    end

    def redhat_deletable?
      !self.promoted? && self.product.provider.editable?
    end

    def syncable?
      organization.syncable?
    end

  end

  module ClassMethods

    def creatable?(product)
      product.editable?
    end

    def readable(env)
      prod_ids = Katello::Product.all_readable(env.organization).collect { |p| p.id }
      where(product_id: prod_ids, :environment_id => env.id)
    end

    def all_syncable(organization)
      organization.syncable?
    end

    def all_deletable(repositories)
      deletable = repositories.collect{|r| r.deletable?}
      !deletable.include?(false)
    end

    def any_readable?(organization)
      Katello::Product.any_readable?(organization)
    end

    def libraries_content_readable(org)
      repos = Repository.content_readable(org)
      lib_ids = []
      repos.each{|r|  lib_ids << (r.library_instance_id || r.id)}
      where(:id => lib_ids)
    end

    def content_readable(org)
      prod_ids = Katello::Product.readable(org).collect{|p| p.id}
      env_ids = LifecycleEnvironment.content_readable(org)
      where(environment_id: env_ids, product_id: prod_ids)
    end

    def readable_for_product(env, prod)
      if env.contents_readable?
        where(environment_id: env.id, product_id: prod.id)
      else
        #none readable
        where("1=0")
      end
    end

    def editable_in_library(org)
      where(environment_id: org.library.id, product_id: Product.editable(org).pluck("#{Katello::Product.table_name}.id"))
    end

    def readable_in_org(org, *skip_library)
      if (skip_library.empty? || skip_library.first.nil?)
        # 'skip library' not included, so retrieve repos in library in the result
        where(environment_id: LifecycleEnvironment.content_readable(org))
      else
        where(environment_id: LifecycleEnvironment.content_readable(org).non_library)
      end
    end

    def any_contents_readable_in_org?(org, skip_library = false)
      LifecycleEnvironment.any_contents_readable?(org, skip_library)
    end
  end

end
end
