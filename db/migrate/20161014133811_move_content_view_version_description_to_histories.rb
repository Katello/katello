class MoveContentViewVersionDescriptionToHistories < ActiveRecord::Migration
  class Katello::ContentViewVersion < ActiveRecord::Base
    has_many :history, :class_name => "Katello::CVHistory", :inverse_of => :content_view_version,
                       :dependent => :destroy, :foreign_key => :katello_content_view_version_id
  end

  class Katello::CVHistory < ActiveRecord::Base
    self.table_name = 'katello_content_view_histories'
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion", :foreign_key => :katello_content_view_version_id, :inverse_of => :history
    SUCCESSFUL = 'successful'.freeze
    scope :successful, -> { where(:status => SUCCESSFUL) }

    enum action: {
      publish: 1,
      promotion: 2,
      removal: 3,
      export: 4
    }
  end

  def up
    Katello::ContentViewVersion.find_each do |version|
      publish_history = version.history.publish.successful.first
      unless publish_history
        publish_history = Katello::CVHistory.create!(action: Katello::CVHistory.actions[:publish],
                                                     katello_content_view_version_id: version.id,
                                                     status: 'successful',
                                                     user: ''
                                                    )
      end

      publish_history.update_attributes!(notes: version[:description])
    end

    remove_column :katello_content_view_versions, :description, :text
  end

  def down
    add_column :katello_content_view_versions, :description, :text
  end
end
