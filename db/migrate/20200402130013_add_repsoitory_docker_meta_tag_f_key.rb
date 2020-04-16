class AddRepsoitoryDockerMetaTagFKey < ActiveRecord::Migration[5.2]
  def up
    Katello::RepositoryDockerMetaTag.where.not(:repository_id => Katello::Repository.select(:id)).delete_all
    Katello::RepositoryDockerMetaTag.where.not(:docker_meta_tag_id => Katello::DockerMetaTag.select(:id)).delete_all

    add_foreign_key :katello_repository_docker_meta_tags, :katello_repositories, :column => :repository_id
    add_foreign_key :katello_repository_docker_meta_tags, :katello_docker_meta_tags, :column => :docker_meta_tag_id

    if Katello::DockerMetaTag.any?
      query = "DELETE FROM katello_repository_docker_meta_tags T1
                USING   katello_repository_docker_meta_tags T2
                WHERE   T1.ctid < T2.ctid
                AND T1.repository_id  = T2.repository_id
                AND T1.docker_meta_tag_id = T2.docker_meta_tag_id;"
      ActiveRecord::Base.connection.execute(query)
    end
    add_index :katello_repository_docker_meta_tags, [:repository_id, :docker_meta_tag_id], :unique => true, :name => 'repository_docker_meta_tags_rid_dmtid'

    Katello::RepositoryDockerTag.where.not(:repository_id => Katello::Repository.select(:id)).delete_all
    Katello::RepositoryDockerTag.where.not(:docker_tag_id => Katello::DockerTag.select(:id)).delete_all

    add_foreign_key :katello_repository_docker_tags, :katello_repositories, :column => :repository_id
    add_foreign_key :katello_repository_docker_tags, :katello_docker_tags, :column => :docker_tag_id

    if Katello::DockerTag.any?
      query = "DELETE FROM katello_repository_docker_tags T1
                USING   katello_repository_docker_tags T2
                WHERE   T1.ctid < T2.ctid
                AND T1.repository_id = T2.repository_id
                AND T1.docker_tag_id = T2.docker_tag_id;"
      ActiveRecord::Base.connection.execute(query)
    end
    add_index :katello_repository_docker_tags, [:repository_id, :docker_tag_id], :unique => true, :name => 'repository_docker_tags_rid_dtid'
  end

  def down
    remove_foreign_key :katello_repository_docker_meta_tags, :katello_repositories
    remove_foreign_key :katello_repository_docker_meta_tags, :katello_docker_meta_tags
    remove_index :katello_repository_docker_meta_tags,  [:repository_id, :docker_meta_tag_id]
    remove_foreign_key :katello_repository_docker_tags, :katello_repositories
    remove_foreign_key :katello_repository_docker_tags, :katello_docker_tags
    remove_index :katello_repository_docker_tags, [:repository_id, :docker_tag_id]
  end
end
