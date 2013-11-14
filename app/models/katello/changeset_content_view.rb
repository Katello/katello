module Katello
class ChangesetContentView < ActiveRecord::Base
  self.include_root_in_json = false

  belongs_to :changeset
  belongs_to :content_view, :class_name => "Katello::ContentView"
end
end
