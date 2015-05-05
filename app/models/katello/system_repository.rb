module Katello
  class SystemRepository < Katello::Model
    self.include_root_in_json = false

    belongs_to :system, :inverse_of => :system_repositories, :class_name => 'Katello::System'
    belongs_to :repository, :inverse_of => :system_repositories, :class_name => 'Katello::Repository'
  end
end
