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

module Actions
  module Katello
    module RepositorySet
      class ScanCdn < Actions::AbstractAsyncTask
        input_format do
          param :product_id
          param :content_id
        end

        output_format do
          param :results, array_of(Hash) do
            param :substitutions
            param :path
            param :repo_id
            param :enabled
          end
        end

        def plan(product, content_id)
          prod_content = product.product_content_by_id(content_id).content

          plan_self(product_id:  product.id, content_id: prod_content.id)
        end

        def run
          output[:results] = fetch_results
        end

        private

        def fetch_results
          if content.type == ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
            prepare_results_docker_content
          else
            cdn_var_substitutor.substitute_vars(content.contentUrl).map do |(substitutions, path)|
              prepare_result(substitutions, path)
            end
          end
        end

        def cdn_var_substitutor
          product.cdn_resource.substitutor
        end

        def prepare_results_docker_content
          registries = product.cdn_resource.get_docker_registries(content.contentUrl)
          registries.map do |registry|
            mapper = ::Katello::Candlepin::Content::DockerRepositoryMapper.new(product,
                                                                content,
                                                                registry['name'])
            mapper.registries = registries
            mapper.registry_repo = registry
            repo = mapper.find_repository

            {
              substitutions: {},
              path:          mapper.feed_url,
              repo_name:     mapper.name,
              pulp_id:       mapper.pulp_id,
              registry_name: registry["name"],
              enabled:       !repo.nil?,
              promoted:      (!repo.nil? && repo.promoted?)
            }
          end
        end

        def prepare_result(substitutions, _path)
          mapper = repository_mapper(substitutions)
          repo = mapper.find_repository
          { substitutions: substitutions,
            path:          mapper.path,
            repo_name:     mapper.name,
            pulp_id:       mapper.pulp_id,
            enabled:       !repo.nil?,
            promoted:      (!repo.nil? && repo.promoted?)
          }
        end

        def product
          @product ||= ::Katello::Product.find(input[:product_id])
        end

        def content
          return @content if defined? @content
          if product_content = product.product_content_by_id(input[:content_id])
            @content = product_content.content
          else
            fail "Couldn't find content '%s'" % input[:content_id]
          end
        end

        def repository_mapper(substitutions)
          ::Katello::Candlepin::Content::RepositoryMapper.new(product,
                                                              content,
                                                              substitutions)
        end

        def cdn_url
          product.provider[:repository_url]
        end
      end
    end
  end
end
