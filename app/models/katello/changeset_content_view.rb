module Katello
class ChangesetContentView < ActiveRecord::Base
  include Katello::ForbiddenAttributesProtection
  self.include_root_in_json = false

  belongs_to :changeset, :inverse_of => :changeset_content_views
  belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :changeset_content_views
end
end
