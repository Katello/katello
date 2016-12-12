namespace :katello do
  desc <<-END_DESC
  Report on hypervisors without VDC subscriptions and guests consuming virtual entitlements.  Returns non-negative exit code if any issue is found.
  Options:
    CSV - Output in csv format.  Example:  CSV=true
    LIMIT - only execute on a specified number of hosts (useful when re-running with different options).  Example:  LIMIT=500
    IGNORE - ignore one or more pools, separated via a pipe character '|'.
      Example:  IGNORE="Red Hat Enterprise Linux Server with Smart Management, Standard (Physical or Virtual Nodes)|Some Other Pool"
END_DESC
  task :virt_who_report => ["environment", "check_ping"] do
    class ProblemItem
      attr_accessor :host, :hypervisor, :message

      def initialize(hash)
        hash.each { |k, v| instance_variable_set("@#{k}", v) }
      end

      def hostname
        host.try(:name)
      end

      def host_id
        host.try(:id)
      end
    end

    def physical_entitlements(entitlements)
      entitlements.select do |ent|
        attributes = ent['pool']['productAttributes'] + ent['pool']["attributes"]
        virtual = attributes.find { |att| att['name'] == 'virt_only' || att['name'] == 'virtual' }.try(:[], 'value') == 'true'
        ent['pool']['quantity'] != -1 && virtual != true
      end
    end

    #version specific methods
    def total_count
      Katello::Host::SubscriptionFacet.count
    end

    def for_each_item_with_index
      Katello::Host::SubscriptionFacet.find_each.with_index do |item, index|
        yield(item, index)
      end
    end

    def candlepin_attributes(item)
      item.candlepin_consumer.consumer_attributes
    end

    def entitlements(item)
      item.candlepin_consumer.entitlements
    end

    def hypervisor_for(item)
      item.candlepin_consumer.virtual_host
    end

    def host_for(item)
      item.host
    end

    #output writing
    def output_txt(directory, hypervisors, guests, errors)
      write_to_file(File.join(directory, 'hypervisors.txt'), hypervisors) do |file, problem|
        file.write("#{problem.hostname} (#{problem.host_id}): #{problem.message}\n")
      end

      write_to_file(File.join(directory, 'guests.txt'), guests) do |file, problem|
        hypervisor_msg = "Could not identify hypervisor."
        hypervisor_msg = "Hypervisor identified as #{problem.hypervisor.name} (#{problem.hypervisor.id})." if problem.hypervisor
        file.write("#{problem.hostname} (#{problem.host_id}): #{problem.message} #{hypervisor_msg}\n")
      end

      write_to_file(File.join(directory, 'errors.txt'), errors) do |file, problem|
        file.write("#{problem.hostname} (#{problem.host_id}): #{problem.message}\n")
      end
    end

    def output_csv(directory, hypervisors, guests, errors)
      hypervisor_header = ['Name', 'Id', 'Problem reason']
      write_to_file(File.join(directory, 'hypervisors.csv'), hypervisors, hypervisor_header) do |file, problem|
        file << [problem.hostname, problem.host_id, problem.message]
      end

      guests_header = ['Name', 'Id', 'Problem reason', 'Hypervisor name', 'Hypervisor id']
      write_to_file(File.join(directory, 'guests.csv'), guests, guests_header) do |file, problem|
        file << [problem.hostname, problem.host_id, problem.message, problem.hypervisor.try(:name), problem.hypervisor.try(:id)]
      end

      errors_header = ['Name', 'Id', 'Error']
      write_to_file(File.join(directory, 'errors.csv'), errors, errors_header) do |file, problem|
        file << [problem.hostname, problem.host_id, problem.message]
      end
    end

    def write_to_file(filename, items, csv_header = nil)
      file_obj = csv_header ? CSV : File
      file_obj.open(filename, 'w') do |file|
        file << csv_header if csv_header
        items.each do |item|
          yield(file, item)
        end
      end
    end

    total = total_count
    guests = []
    hypervisors = []
    errors = []
    ignored_pools = ENV['IGNORE'] ? ENV['IGNORE'].split('|') : []

    for_each_item_with_index do |item, index|
      break if ENV['LIMIT'] && ENV['LIMIT'].to_i < index
      puts "#{index + 1}/#{total}"
      begin
        consumer_attributes = candlepin_attributes(item)
        entitlements = entitlements(item)
        if consumer_attributes['type']['label'] == 'hypervisor' && entitlements.empty?
          hypervisors << ProblemItem.new(:host => host_for(item), :message => "Has no entitlements")
        elsif consumer_attributes['facts']['virt.is_guest'].try(:to_s) == 'true'
          physical_ents = physical_entitlements(entitlements).select { |ent| !ignored_pools.include?(ent) }

          if physical_ents.count > 0
            names = physical_ents.map { |ent| ent['pool']['productName'] }.join(',')
            guests << ProblemItem.new(:host => host_for(item), :message => "Has physical entitlements: #{names}.", :hypervisor => hypervisor_for(item))
          end
        end
      rescue StandardError => e
        errors << ProblemItem.new(:host => host_for(item), :message => e.to_s)
      end
    end

    directory = Dir.mktmpdir('virt_who_report')
    if hypervisors.any? || guests.any? || errors.any?
      puts "#{hypervisors.count} hypervisor issues found."
      puts "#{guests.count} guest issues found."
      puts "#{errors.count} errors encountered."
      puts "Saving results to #{directory}/."

      if ENV['CSV'] && ENV['CSV'] == 'true'
        output_csv(directory, hypervisors, guests, errors)
      else
        output_txt(directory, hypervisors, guests, errors)
      end
      exit(-1)
    else
      puts "No issues found."
    end
  end
end
