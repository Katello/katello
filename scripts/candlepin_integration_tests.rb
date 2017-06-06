require 'openssl'
require 'rubygems'
require 'nokogiri'
require 'net/scp'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

username = ARGV[0]
password = ARGV[1]

beaker_start_output = %x[/usr/bin/bkr workflow-simple --username="#{username}"  --password="#{password}" --distro="Fedora-14" --whiteboard="Reserve F14 and puppet apply: candlepin, pulp" --arch=x86_64 --keyvalue="MEMORY>499" --keyvalue="DISK>6999" --task=/Kalpana/Sanity/ImportKeys --taskparam='PUBKEYS=lzap witlessb hudson_rsa' --task=/Kalpana/Installation/InstallPuppet --task=/Kalpana/Integration/RunSpec --taskparam='SPECDIRS=candlepin' --task=/distribution/reservesys]

unless beaker_start_output =~ /^Submitted:\s*\['J:(\d+)'\]/
  p "failed to start beaker job: #{beaker_start_output}" 
  exit(1)
end

job_id =$1
job_status = ""
begin
  job = Nokogiri::XML(%x[bkr job-results J:#{job_id}])
  job_result = job.xpath("//task[@name='/distribution/reservesys']/results/result[@path='/distribution/reservesys']/@result").to_s
  job_status = job.xpath("//task[@name='/distribution/reservesys']/@status").to_s
  sleep(60) unless job_result == "Pass" || job_status == "Aborted" 
end until job_result == "Pass" || job_status == "Aborted"

if job_status == "Aborted"
  p "job was aborted: #{job}"
  exit(1)
end

host = job.xpath("//recipe/@system").to_s
begin
  Net::SCP.start(host.to_s, "root", :keys => "/home/hudson/.ssh/hudson_rsa") do |scp|
    scp.download!("/mnt/tests/Kalpana/Integration/RunSpec/katello/src/hudson", "./", :recursive => true, :ssh => "/home/hudson/.ssh/hudson_rsa")
  end
rescue Exception => e
  p "Error retrieving test results: #{e.to_s}"
end

#%x[/usr/bin/bkr system-release "#{host}"]
