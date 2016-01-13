module Katello
  module Concerns
    module RepositoryTypes
      module DockerExtensions
        extend ActiveSupport::Concern
        DOCKER_TYPE = 'docker'

        module ClassMethods
          def clone_docker_repo_path(options)
            repo = options[:repository]
            org = repo.organization.label.downcase
            if options[:environment]
              cve = ContentViewEnvironment.where(:environment_id => options[:environment],
                                                 :content_view_id => options[:content_view]).first
              view = repo.content_view.label
              product = repo.product.label
              env, _ = cve.label.split('/')
              "#{org}-#{env.downcase}-#{view}-#{product}-#{repo.label}"
            else
              content_path = repo.relative_path.gsub("#{org}-", '')
              "#{org}-#{options[:content_view].label}-#{options[:version].version}-#{content_path}"
            end
          end
        end

        included do
          before_create :downcase_pulp_id
          has_many :repository_docker_images, :class_name => "Katello::RepositoryDockerImage", :dependent => :destroy
          has_many :docker_images, :through => :repository_docker_images
          has_many :docker_tags, :dependent => :destroy, :class_name => "Katello::DockerTag"

          validates :docker_upstream_name, :allow_blank => true, :if => :docker?, :format => {
            :with => /\A([a-z0-9\-_]{4,30}\/)?[a-z0-9\-_\.]{3,30}\z/,
            :message => (_("must be a valid docker name"))
          }

          validate :ensure_valid_docker_attributes, :if => :docker?
          validate :ensure_docker_repo_unprotected, :if => :docker?

          scope :docker_type, -> { where(:content_type => DOCKER_TYPE) }
        end

        def downcase_pulp_id
          # Docker doesn't support uppercase letters in repository names.  Since the pulp_id
          # is currently being used for the name, it will be downcased for this content type.
          if self.content_type == Repository::DOCKER_TYPE
            self.pulp_id = self.pulp_id.downcase
          end
        end

        def container_repository_name
          pulp_id if docker?
        end

        def ensure_valid_docker_attributes
          if url.blank? != docker_upstream_name.blank?
            field = url.blank? ? :url : :docker_upstream_name
            errors.add(field, N_("cannot be blank. Either provide all or no sync information."))
            errors.add(:base, N_("Repository URL or Upstream Name is empty. Both are required for syncing from the upstream."))
          end
        end

        def ensure_docker_repo_unprotected
          unless unprotected
            errors.add(:base, N_("Docker Repositories are not protected at this time. " \
                                 "They need to be published via http to be available to containers."))
          end
        end

        def docker?
          content_type == DOCKER_TYPE
        end

        def remove_docker_content(images)
          self.docker_tags.where(:docker_image_id => images.map(&:id)).destroy_all
          self.docker_images -= images

          # destroy any orphan docker images
          images.reload.each do |image|
            image.destroy if image.repositories.empty?
          end
        end
      end
    end
  end
end
