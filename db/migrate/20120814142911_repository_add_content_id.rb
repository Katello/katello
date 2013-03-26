class RepositoryAddContentId < ActiveRecord::Migration
  def self.up
    add_column :repositories, :content_id, :string, :null=>true

    User.current = User.hidden.first
    groups = Runcible::Resources::RepositoryGroup.retrieve_all
    groups.each do |group|
      group_id = group['id']
      split_id = group_id.split(':')
      if split_id.length == 2 && split_id[0] == 'content'
        group['repo_ids'].each do |repo_id|
          repo = Reepository.where(:pulp_id=>repo_id)
          repo.content_id = split_id[1]
          repo.save!
        end
        Runcible::Resources::RepositoryGroup.destroy(group_id)
      end
    end 
    
    found = Repository.where(:content_id=>nil).pluck(:name)
    puts "Found repos with nil content_id: #{found.join(', ')}\n" if !found.empty?
    change_column :repositories, :content_id, :string, :null=>false
  end

  def self.down
    remove_column :repositories, :content_id
  end
end
