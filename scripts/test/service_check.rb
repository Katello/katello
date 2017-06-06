require 'rest_client'
require 'resources/pulp'
require 'resources/candlepin'


def check_services
  results = Ping.ping()
  status = results[:status]
  errors = false
  for k in status.keys do
    service_result = status[k][:result]
    if service_result != "ok"
      errors = true
      puts ""
      puts "!! FATAL CONFIGURATION ERROR, We can't start until we can connect to all services."
      puts "!! We ran into a problem connecting trying [#{k}] and got this error: "
      puts "     #{status[k][:message]}"
      puts ""
    end
  end

  if errors
    abort("Fatal configuration errors must be corrected before startup can continue.")
  end
end

server_mode = $PROGRAM_NAME.end_with?("rails")

check_services unless !server_mode
