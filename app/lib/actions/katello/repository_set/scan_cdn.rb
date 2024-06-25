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
          plan_self(product_id: product.id, content_id: content_id)
        end

        def run
          output[:results] = fetch_results
        end

        private

        def fetch_results
          substitutor = cdn_var_substitutor
          return [] unless substitutor
          substitutor.substitute_vars(content.content_url).map do |path_with_substitutions|
            prepare_result(path_with_substitutions.substitutions, path_with_substitutions.path)
          end
        end

        def cdn_var_substitutor
          return unless (cdn_resource = product.cdn_resource)
          cdn_resource.substitutor
        end

        def prepare_result(substitutions, _path)
          mapper = repository_mapper(substitutions)
          repo = mapper.find_repository
          unique_id = repo.try(:pulp_id) || SecureRandom.uuid
          { substitutions: substitutions,
            path: mapper.path,
            repo_name: mapper.name,
            pulp_id: unique_id,
            name: mapper.content.name,
            enabled: !repo.nil?,
            promoted: (!repo.nil? && repo.promoted?),
            repository_id: repo.try(:id),
          }
        end

        def product
          @product ||= ::Katello::Product.find(input[:product_id])
        end

        def content
          return @content if defined? @content
          if (product_content = product.product_content_by_id(input[:content_id]))
            @content = product_content.content
          else
            fail "Couldn't find content '%s'" % input[:content_id]
          end
        end

        def repository_mapper(substitutions)
          ::Katello::Candlepin::RepositoryMapper.new(product,
                                                     content,
                                                     substitutions)
        end
      end
    end
  end
end
