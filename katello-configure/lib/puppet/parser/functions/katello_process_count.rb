module Puppet::Parser::Functions
  # it takes one argument: resources_portion, which means what part of
  # available memory should be considered when calculating the
  # processes. The main motivation for this is to reuse this function
  # to calculate number of processes for both Katello and Foreman.
  newfunction(:katello_process_count, :type => :rvalue) do |args|
    resources_portion = args.first || 1
    begin
      cpu_count = lookupvar('::processorcount').to_i
      consumes = 230_000_000 # for each thin process
      reserve = 2_000_000_000 # for the OS and backend engines
      mem,unit = lookupvar('::memorysize').split

      # convert total memory into bytes
      total_mem = mem.to_f 
      case unit 
        when nil  then total_mem *= (1<<0) 
        when 'kB' then total_mem *= (1<<10) 
        when 'MB' then total_mem *= (1<<20) 
        when 'GB' then total_mem *= (1<<30) 
        when 'TB' then total_mem *= (1<<40) 
      end

      notice("CPU count: #{cpu_count}")
      no_processes = cpu_count + 1
      notice("Thin processes recommendation: #{no_processes}")

      # calculate number of processes
      notice("Total memory: #{total_mem}")
      notice("Thin consumes: #{consumes}")
      notice("Reserve: #{reserve}")
      notice("Portion: #{resources_portion}")

      max_processes = (((total_mem - reserve)*resources_portion / consumes)).floor
      notice("Maximum processes: #{max_processes}")

      # safeguard not to have less than 2 or more than max
      no_processes = max_processes if no_processes > max_processes
      no_processes = 2 if no_processes < 2

      notice("Thin processes: #{no_processes}")
      no_processes.to_s
    rescue Exception => e
      # when anything goes wrong return a decent constant
      '2'
    end
  end
end
