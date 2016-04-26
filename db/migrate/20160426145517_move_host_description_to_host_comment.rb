class MoveHostDescriptionToHostComment < ActiveRecord::Migration
  class Host < ActiveRecord::Base
    self.table_name = "hosts"
  end

  def up
    Host.find_each do |host|
      if host.comment.empty?
        host.comment = host.description
      else
        host.comment = [host.comment, host.description].join("\n") unless host.description.empty?
      end
      host.save!
    end

    remove_column :hosts, :description
  end

  def down
    add_column :hosts, :description, :text

    Host.find_each do |host|
      host.description = host.comment
      host.comment = nil
      host.save!
    end
  end
end
