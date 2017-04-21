module Katello
  class ErratumBugzilla < Katello::Model
    belongs_to :erratum, :inverse_of => :bugzillas, :class_name => 'Katello::Erratum'
  end
end
