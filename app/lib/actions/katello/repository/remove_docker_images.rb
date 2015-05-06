module Actions
  module Katello
    module Repository
      class RemoveDockerImages < Actions::EntryAction
        def plan(options)
          plan_self(options)
        end

        def run
          repo = ::Katello::Repository.in_default_view.find_by_pulp_id(input['pulp_id'])
          images = repo.docker_images.with_uuid(input['uuids'])
          repo.docker_tags.where(:docker_image_id => images.map(&:id)).destroy_all
          repo.docker_images -= images

          # destroy any orphan docker images
          images.reload.each do |image|
            image.destroy if image.repositories.count < 1
          end
        end
      end
    end
  end
end
