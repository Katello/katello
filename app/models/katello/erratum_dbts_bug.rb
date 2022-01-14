module Katello
  class ErratumDbtsBug < Katello::Model
    belongs_to :erratum, inverse_of: :dbts_bugs, class_name: 'Katello::Erratum'

    def href
      "https://bugs.debian.org/#{bug_id}"
    end
  end
end
