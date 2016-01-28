module Katello
  class ErratumBugzilla < Katello::Model
    self.include_root_in_json = false

    belongs_to :erratum, :inverse_of => :bugzillas, :class_name => 'Katello::Erratum'
  end
end
