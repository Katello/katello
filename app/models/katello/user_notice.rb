module Katello
  class UserNotice < Katello::Model
    self.include_root_in_json = false

    belongs_to :user, :inverse_of => :user_notices, :class_name => "::User"
    # FIXME, this will delete notice also for other users
    belongs_to :notice, :dependent => :destroy, :inverse_of => :user_notices

    validates_lengths_from_database

    def read!
      update_attributes! :viewed => true
    end
  end
end
