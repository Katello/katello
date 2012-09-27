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


module Authorization::Repository
  def self.included(base)
    base.class_eval do

      def self.in_product(product)
        joins(:environment_product).where(:environment_products => { :product_id => product })
      end

      def self.in_environment(env)
        joins(:environment_product).where(:environment_products => { :environment_id => env })
      end

      def self.readable(env)
        prod_ids = ::Product.readable(env.organization).collect{|p| p.id}
        if env.contents_readable?
          joins(:environment_product).where("environment_products.environment_id" => env.id)
        else
          #none readable
          where("1=0")
        end
      end

      def self.libraries_content_readable(org)
        repos = Repository.enabled.content_readable(org)
        lib_ids = []
        repos.each{|r|  lib_ids << (r.library_instance_id || r.id)}
        where(:id=>lib_ids)
      end

      def self.content_readable(org)
          prod_ids = ::Product.readable(org).collect{|p| p.id}
          env_ids = KTEnvironment.content_readable(org)
          joins(:environment_product).where("environment_products.product_id" => prod_ids).
              where("environment_products.environment_id"=>env_ids)
      end

      def self.readable_for_product(env, prod)
        if env.contents_readable?
          joins(:environment_product).where("environment_products.environment_id" => env.id).where(
                                    'environment_products.product_id'=>prod.id)
        else
          #none readable
          where("1=0")
        end
      end

      def self.editable_in_library(org)
        joins(:environment_product).
            where("environment_products.environment_id" => org.library.id).
            where("environment_products.product_id in (#{Product.editable(org).select("products.id").to_sql})")
      end

      def self.readable_in_org(org, *skip_library)
        if (skip_library.empty? || skip_library.first.nil?)
          # 'skip library' not included, so retrieve repos in library in the result
          joins(:environment_product).where("environment_products.environment_id" =>  KTEnvironment.content_readable(org))
        else
          joins(:environment_product).where("environment_products.environment_id" =>  KTEnvironment.content_readable(org).where(:library => false))
        end
      end

      def self.any_readable_in_org? org, skip_library = false
        KTEnvironment.any_contents_readable? org, skip_library
      end
    end

  end

end
