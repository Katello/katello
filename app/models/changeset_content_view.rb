class ChangesetContentView < ActiveRecord::Base
  belongs_to :changeset, :inverse_of => :changeset_content_views
  belongs_to :content_view, :inverse_of => :changeset_content_views
end
