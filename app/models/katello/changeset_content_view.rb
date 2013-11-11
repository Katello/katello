module Katello
class ChangesetContentView < ActiveRecord::Base
  self.include_root_in_json = false

  belongs_to :changeset, :inverse_of => :changeset_content_views
  belongs_to :content_view, :inverse_of => :changeset_content_views
end
end
