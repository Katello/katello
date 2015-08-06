module Katello
  module Concerns
    module ContainerExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :capsule, :inverse_of => :containers, :foreign_key => :capsule_id,
          :class_name => "SmartProxy"

        alias_method_chain :repository_pull_url, :katello
      end

      def repository_pull_url_with_katello
        repo_url = repository_pull_url_without_katello
        if Repository.where(:pulp_id => repository_name).count > 0
          image_capsule = self.capsule  || CapsuleContent.default_capsule.capsule
          "#{URI(image_capsule.url).hostname}:5000/#{repo_url}"
        else
          repo_url
        end
      end
    end
  end
end
