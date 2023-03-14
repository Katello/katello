class EnsureRepoUsernamePasswordNilNotBlank < ActiveRecord::Migration[6.1]
  def change
    ::Katello::Repository.library.each do |repo|
      if repo.upstream_username == '' && repo.upstream_password == ''
        repo.root.update(upstream_username: nil, upstream_password: nil)
      end
    end
  end
end
