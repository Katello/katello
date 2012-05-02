module Puppet::Parser::Functions
  newfunction(:katello_process_count, :type => :rvalue) do |args|
    begin
      cpu_count = lookupvar('::processorcount').to_i
      consumes = 230_000_000 # for each thin process
      reserve = 2_000_000_000 # for the OS and backend engines
      mem,unit = lookupvar('::memorysize').split

      # convert total memory into bytes
      total_mem = mem.to_f 
      case unit 
        when nil:  total_mem *= (1<<0) 
        when 'kB': total_mem *= (1<<10) 
        when 'MB': total_mem *= (1<<20) 
        when 'GB': total_mem *= (1<<30) 
        when 'TB': total_mem *= (1<<40) 
      end

      notice("CPU count: #{cpu_count}")
      no_processes = cpu_count + 1
      notice("Thin processes recommendation: #{no_processes}")

      # calculate number of processes
      notice("Total memory: #{total_mem}")
      notice("Thin consumes: #{consumes}")
      notice("Reserve: #{reserve}")
      max_processes = (((total_mem - reserve) / consumes)).floor
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
