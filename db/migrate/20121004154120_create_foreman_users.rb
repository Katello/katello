class CreateForemanUsers < ActiveRecord::Migration
  def self.up
    User.current = User.find_by_username 'admin'
    User.all.each do |u|
      u.save!
    end
  end

  def self.down
  end
end
