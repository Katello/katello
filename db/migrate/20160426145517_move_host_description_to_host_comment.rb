class MoveHostDescriptionToHostComment < ActiveRecord::Migration
  class Host < ActiveRecord::Base
    self.table_name = "hosts"
  end

  def up
    Host.find_each do |host|
      new_comment = nil
      if host.comment.blank?
        new_comment = host.description
      else
        new_comment = [host.comment, host.description].join("\n") unless host.description.empty?
      end
      host.update_column(:comment, new_comment) if new_comment
    end

    remove_column :hosts, :description
  end

  def down
    add_column :hosts, :description, :text

    Host.find_each do |host|
      host.update_columns(:comment => nil, :description => host.comment)
    end
  end
end
