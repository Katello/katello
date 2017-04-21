module Katello
  class ContentViewPuppetEnvironmentPuppetModule < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :content_view_puppet_environment,
               :inverse_of => :content_view_puppet_environment_puppet_modules,
               :class_name => 'Katello::ContentViewPuppetEnvironment'
    belongs_to :puppet_module,
               :inverse_of => :content_view_puppet_environment_puppet_modules,
               :class_name => 'Katello::PuppetModule'
  end
end
