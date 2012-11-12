class RepositoryAddContentView < ActiveRecord::Migration
  def self.up
    add_column :repositories, :content_view_id, :integer, :null=>true
    add_index :repositories, :content_view_id
    
    KTEnvironment.all.each do |env|
     view = ContentView.create!(:name=>"Default View for #{env.name}", 
                         :organization=>env.organization)
     env.default_content_view = view
     env.save!
     env.repositories.each do |repo|
       repo.content_view = view
       view.save!
     end
    end
     
    change_column :repositories, :content_view_id, :integer, :null => false
  end

  def self.down
    remove_column :repositories, :content_view_id
  end
end
