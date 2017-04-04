require File.expand_path("../engine", File.dirname(__FILE__))

# Use when regenerating the CA on the system, i.e. a hostname change
namespace :katello do
  desc 'Regenerates the ueber cert for each organization in candlepin, can be passed an organization label.'
  task :regenerate_ueber_certs, [:organization] => :environment do |_t, args|
    user_org = Organization.where(:label => args.organization).first if args.organization
    organizations = user_org.present? ? [user_org] : Organization.all

    organizations.each do |org|
      org.regenerate_ueber_cert
    end
    puts "Regenerated the ueber certificate(s) for #{organizations.map(&:name).join(', ')}"
  end
end
