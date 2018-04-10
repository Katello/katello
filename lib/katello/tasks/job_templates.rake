namespace :katello do
  desc "Synchronize Ansible job templates with lates community templates"
  task :sync_ansible_job_templates => :environment do
    template_repository = "https://github.com/theforeman/community-templates"
    Dir.mktmpdir  do |dir|
      system("git clone -q -b develop #{template_repository} #{dir}/ct")
      Dir.chdir "#{Katello::Engine.root}/app/views/foreman"
      system("rsync -am \
        --include='*katello_ansible_default*' \
        --exclude='*' \
        #{dir}/ct/job_templates/* ./job_templates")
      Dir.chdir Katello::Engine.root
      system("git status -- app/views/foreman_ansible/job_templates")
    end
  end
end
