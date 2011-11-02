module Puppet::Parser::Functions
  newfunction(:katello_process_count, :type => :rvalue) do |args|
    begin
      cpu_count = scope.lookupvar('::processorcount')
      consumes = 230_000_000 # for each thin process
      reserve = 500_000_000 # for the OS
      mem,unit = scope.lookupvar('::memorysize').split 

      # convert total memory into bytes
      total_mem = mem.to_f 
      case unit 
        when nil:  total_mem *= (1<<0) 
        when 'kB': total_mem *= (1<<10) 
        when 'MB': total_mem *= (1<<20) 
        when 'GB': total_mem *= (1<<30) 
        when 'TB': total_mem *= (1<<40) 
      end

      # calculate number of processes
      no_processes = (((total_mem - reserve) / (cpu_count * consumes))).floor

      # safeguard not to return bigger number then cpu count + 1
      no_processes = cpu_count + 1 if no_processes > cpu_count * 2

      no_processes
    rescue Exception => e
      # when anything goes wrong return a decent constant
      2
    end
  end
end
