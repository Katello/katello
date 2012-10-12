class EnvironmentContentView < ActiveRecord::Base
  belongs_to :environment, :class_name => "KTEnvironment",
    :foreign_key => :environment_id
  belongs_to :content_view
end
