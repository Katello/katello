module Katello
  class SystemErratum < Katello::Model
    self.include_root_in_json = false

    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :system, :inverse_of => :system_errata, :class_name => 'Katello::System'
    belongs_to :erratum, :inverse_of => :system_errata, :class_name => 'Katello::Erratum'
  end
end
