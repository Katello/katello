module Katello
  class ChangesetContentView < ActiveRecord::Base
    belongs_to :changeset
    belongs_to :content_view
  end
end
