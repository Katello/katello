class AddUpstreamNameToRepository < ActiveRecord::Migration
  def up
    add_column :katello_repositories, :docker_upstream_name, :string
    Katello::Repository.docker_type.each do |repo|
      update %(
        update #{Katello::Repository.table_name}
              set docker_upstream_name=#{ActiveRecord::Base.sanitize(repo.name)}
              where id=#{repo.id}
      ).gsub(/\s+/, " ").strip
    end
  end

  def down
    remove_column :katello_repositories, :docker_upstream_name
  end
end
