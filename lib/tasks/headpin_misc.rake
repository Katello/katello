#mainly to populate the existing orgs with a "headpin" environment since all orgs will implicitly have this
#task to perform steps required for katello to work
desc 'For headpin developers to run to ensure that ll orgs have the default env.'
task :headpin_create_envs => :environment do
  puts "Loading organizations"
  Organization.all.each do |org|
    puts "Org #{org.name}"
    if !Katello.config.katello?
      env_params = {:name => "Headpin",
                    :description => "Default environment for Headpin",
                    :prior => org.library.id,
                    :organization_id => org.id}
      environment =  KTEnvironment.new env_params
      puts "Saving default environment"
      environment.save!
    end
  end
end
