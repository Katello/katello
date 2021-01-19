class DeletePuppetAndOstreeRepos < ActiveRecord::Migration[6.0]
  class FakeContentViewPuppetModule < Katello::Model
    self.table_name = 'katello_content_view_puppet_modules'
  end

  class FakeContentViewPuppetEnvironmentPuppetModule < Katello::Model
    self.table_name = 'katello_content_view_puppet_environment_puppet_modules'
  end

  class FakeRepositoryPuppetModule < Katello::Model
    self.table_name = 'katello_repository_puppet_modules'
  end

  class FakeContentViewPuppetEnvironment < Katello::Model
    self.table_name = 'katello_content_view_puppet_environments'
  end
  class FakePuppetModule < Katello::Model
    self.table_name = 'katello_puppet_modules'
  end
  class FakeRepositoryOstreeBranch < Katello::Model
    self.table_name = 'katello_repository_ostree_branches'
  end
  class FakeOstreeBranch < Katello::Model
    self.table_name = 'katello_ostree_branches'
  end

  def up
    if Katello::Repository.ostree_type.any? || Katello::Repository.puppet_type.any?
      User.as_anonymous_admin do
        FakeContentViewPuppetModule.delete_all
        FakeContentViewPuppetEnvironmentPuppetModule.delete_all
        FakeRepositoryPuppetModule.delete_all

        FakeContentViewPuppetEnvironment.delete_all
        FakePuppetModule.delete_all

        Katello::Repository.puppet_type.delete_all

        FakeRepositoryOstreeBranch.delete_all
        FakeOstreeBranch.delete_all
        Katello::Repository.ostree_type.where.not(:library_instance_id => nil, :environment_id => nil).destroy_all #CV LCE repos
        Katello::Repository.ostree_type.where.not(:library_instance_id => nil).destroy_all # archive repos
        Katello::Repository.ostree_type.destroy_all #all the rest (should just be library repos)

        Katello::ContentViewVersion.where.not(:content_counts => nil).each do |version|
          version.content_counts.except!('ostree', 'puppet_module')
          version.save
        end
      end
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
