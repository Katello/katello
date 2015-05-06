module Actions
  module Pulp
    module Repository
      class CopyDockerTag  < Pulp::Abstract
        input_format do
          param :source_pulp_id
          param :target_pulp_id
        end

        def run
          repo = ::Katello::Repository.find_by_pulp_id(input[:source_pulp_id])
          output[:response] = pulp_extensions.repository.update_docker_tags(input[:target_pulp_id], repo.docker_image_tag_hash)
        end
      end
    end
  end
end
