class MoveContentViewVersionDescriptionToHistories < ActiveRecord::Migration[4.2]
  class FakeContentViewVersion < ApplicationRecord
    self.table_name = 'katello_content_view_versions'
    has_many :history, :class_name => "CVHistory", :inverse_of => :content_view_version,
                       :dependent => :destroy, :foreign_key => :katello_content_view_version_id
  end

  class CVHistory < ApplicationRecord
    self.table_name = 'katello_content_view_histories'
    belongs_to :content_view_version, :class_name => "FakeContentViewVersion", :foreign_key => :katello_content_view_version_id, :inverse_of => :history
    SUCCESSFUL = 'successful'.freeze
    scope :successful, -> { where(:status => SUCCESSFUL) }

    enum action: {
      publish: 1,
      promotion: 2,
      removal: 3,
      export: 4,
    }
  end

  def up
    FakeContentViewVersion.find_each do |version|
      publish_history = version.history.publish.successful.first
      publish_history ||= CVHistory.create!(action: CVHistory.actions[:publish],
                                            katello_content_view_version_id: version.id,
                                            status: 'successful',
                                            user: '',
                                            created_at: version.created_at
                                           )

      publish_history.update!(notes: version[:description])
    end

    remove_column :katello_content_view_versions, :description, :text
  end

  def down
    add_column :katello_content_view_versions, :description, :text
  end
end
