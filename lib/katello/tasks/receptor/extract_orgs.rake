namespace :katello do
  namespace :receptor do
    desc 'Extract Organization details for Receptor and write to OUTPUT_FILE.'
    task :extract_orgs => ["dynflow:client", "check_ping"] do
      output_file = ENV['OUTPUT_FILE']

      unless output_file
        fail("The OUTPUT_FILE environment variable must be specified")
      end

      data = Organization.with_upstream_pools.map do |org|
        {
          id: org.id,
          redhat_account_number: org.redhat_account_number,
          cert: org.owner_details.dig(:upstreamConsumer, :idCert, :cert),
          key: org.owner_details.dig(:upstreamConsumer, :idCert, :key),
        }
      end

      File.write(output_file, JSON.pretty_generate(data))

      puts "Wrote results to #{output_file}. Please delete it when finished."
    end
  end
end
