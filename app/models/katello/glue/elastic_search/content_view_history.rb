module Katello
  module Glue::ElasticSearch::ContentViewHistory
    extend ActiveSupport::Concern

    included do
      include Ext::IndexedModel

      index_options :extended_json => :extended_index_attrs,
                    :json => {:only => [:user, :id, :created_at, :updated_at]}

      mapping do
        indexes :version_id, :type => 'integer'
        indexes :created_at, :type => 'date'
        indexes :environment, :type => 'string'
        indexes :content_view_id, :type => 'integer'
        indexes :version, :type => 'float'
        indexes :user, :type => 'string'
      end
    end

    def extended_index_attrs
      {
        :environment => self.environment.try(:name),
        :version_id => self.version.id,
        :version => self.version.version,
        :content_view_id => self.content_view.id,
        :environment_id => self.katello_environment_id
      }
    end
  end
end
