module Katello
  class SearchHistory < Katello::Model
    self.include_root_in_json = false

    belongs_to :user, :inverse_of => :search_histories, :class_name => "::User"
    validates_lengths_from_database
    validates :params, :length => { :maximum => 255 }
    validates :path, :length => { :maximum => 255 }
  end
end
