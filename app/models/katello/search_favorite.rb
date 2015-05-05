module Katello
  class SearchFavorite < Katello::Model
    self.include_root_in_json = false

    include SearchHelper

    belongs_to :user, :inverse_of => :search_favorites, :class_name => "::User"
    validates_lengths_from_database
    validate :max_favorites
    validates :params, :length => { :maximum => 255 }
    validates :path, :length => { :maximum => 255 }

    def max_favorites
      if new_record?
        path = self.attributes["path"]
        if count_favorites(path) >= max_search_favorites
          errors.add(:base, _("Only %s favorites may be created.") % max_search_favorites)
        end
      end
    end

    def count_favorites(path)
      SearchFavorite.where(:user_id => self.user_id, :path => path).count(:id)
    end
  end
end
