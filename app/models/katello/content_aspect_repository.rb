module Katello
  class ContentAspectRepository < Katello::Model
    self.include_root_in_json = false

    belongs_to :content_aspect, :inverse_of => :content_aspect_repositories, :class_name => 'Katello::Host::ContentAspect'
    belongs_to :repository, :inverse_of => :content_aspect_repositories, :class_name => 'Katello::Repository'
  end
end
