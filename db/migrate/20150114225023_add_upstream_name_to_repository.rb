class AddUpstreamNameToRepository < ActiveRecord::Migration[4.2]
  class FakeRepository < ApplicationRecord
    self.table_name = 'katello_repositories'
    scope :docker_type, -> { where(:content_type => 'docker') }
  end

  def up
    add_column :katello_repositories, :docker_upstream_name, :string, :limit => 255
    FakeRepository.docker_type.each do |repo|
      next if repo.url.blank?
      update %(
        update #{FakeRepository.table_name}
              set docker_upstream_name=#{ActiveRecord::Base.sanitize(repo.name)}
              where id=#{repo.id}
      ).gsub(/\s+/, " ").strip
    end
  end

  def down
    remove_column :katello_repositories, :docker_upstream_name
  end
end
