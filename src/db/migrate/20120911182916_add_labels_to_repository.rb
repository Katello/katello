class AddLabelsToRepository < ActiveRecord::Migration
  def self.up
    change_table(:repositories) do
      |t| t.column :label, :string, :bulk => true
      Repository.all.each do |repo|
        execute "update repositories set label = '#{repo.name}' where id= #{repo.id}"
      end
    end
  end

  def self.down
    change_table(:repositories) { |t| t.remove :label}
  end
end
