class FixInvalidInterfaces < ActiveRecord::Migration[4.2]
  class FakeNic < ApplicationRecord
    self.table_name = 'nics'

    def type
      Nic::Base
    end
  end

  def up
    FakeNic.where(:ip => "Unknown").each do |nic|
      nic.update(:ip => nil)
    end
  end
end
