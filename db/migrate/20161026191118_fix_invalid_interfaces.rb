class FixInvalidInterfaces < ActiveRecord::Migration
  class FakeNic < ActiveRecord::Base
    self.table_name = 'nics'

    def type
      Nic::Base
    end
  end

  def up
    FakeNic.where(:ip => "Unknown").each do |nic|
      nic.update_attributes(:ip => nil)
    end
  end
end
