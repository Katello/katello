class SetErrataUpdatedDate < ActiveRecord::Migration[5.0]
  def up
    Katello::Erratum.where(:updated => nil).find_each do |erratum|
      erratum.update(:updated => erratum.issued)
    end
  end
end
