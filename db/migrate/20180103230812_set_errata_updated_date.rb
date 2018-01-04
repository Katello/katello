class SetErrataUpdatedDate < ActiveRecord::Migration[5.0]
  def up
    Katello::Erratum.where(:updated => nil).find_each do |erratum|
      erratum.update_attributes(:updated => erratum.issued)
    end
  end
end
