module Katello
  class HelpTip < Katello::Model
    self.include_root_in_json = false

    belongs_to :user, :inverse_of => :help_tips, :class_name => "::User"
    validates_lengths_from_database
  end
end
