class FillInContentViewComponents < ActiveRecord::Migration
  class FakeContentView < ApplicationRecord
    self.table_name = 'katello_content_views'

    has_many :content_view_components, :class_name => "FakeContentViewVersion", :dependent => :destroy,
             :inverse_of => :composite_content_view, :foreign_key => :composite_content_view_id
  end

  class FakeContentViewVersion < ApplicationRecord
    self.table_name = 'katello_content_view_versions'

    has_many :content_view_components, :inverse_of => :content_view_version, :dependent => :destroy, :class_name => 'FakeContentViewComponent'
  end

  class FakeContentViewComponent < ApplicationRecord
    self.table_name = 'katello_content_view_components'

    belongs_to :content_view_version, :class_name => "FakeContentViewVersion",
                              :inverse_of => :content_view_components
    belongs_to :content_view, :class_name => "FakeContentView",
                              :inverse_of => :component_composites
  end

  def up
    FakeContentViewComponent.find_each do |cvc|
      if cvc.content_view_id.nil? && cvc.content_view_version_id
        cvc.content_view_id = cvc.content_view_version.content_view_id
        cvc.save!
      end
    end
  end
end
