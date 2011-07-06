
def random rng, length = 8
  o =  rng.map{|i| i.to_a}.flatten;  
  (0..length-1).map{ o[rand(o.length)]  }.join
end

def rand_alpha length = 8
  random [('a'..'z'),('A'..'Z')], length
end

def rand_hex length = 8
  random [('a'..'f'), ('0'..'9')], length
end

def rand_mac 
  #"08=>00=>27=>c6=>1b=>dd"
  (0..5).collect{rand_hex 2}.join("=>")
end

def rand_uuid
  #"600229d6-8c5b-4c3d-9098-03c0a639a5f9"
  #"  xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  "#{rand_hex 8}-#{rand_hex 4}-4#{rand_hex 3}-#{random([('0'..'9'),('a'..'b')], 1)}#{rand_hex 3}-#{rand_hex 12}"
end

User.current = User.first

suffix = rand 100
sys ="system-#{suffix}" 
o = Organization.first
e = KPEnvironment.create! :name=> "Scooby-#{suffix}", :prior=>o.locker.id, :organization=>o


ip = (0..2).collect{rand(255).to_s}.join(".") 

facts = {
    "dmi.bios.runtime_size"=> "128 KB",
    "lscpu.cpu_op-mode(s)"=> "64-bit",
    "uname.sysname"=> "Linux",
    "distribution.name"=> "Fedora",
    "dmi.system.family"=> "Virtual Machine",
    "lscpu.l1d_cache"=> "32K",
    "dmi.system.product_name"=> "VirtualBox",
    "dmi.bios.address"=> "0xe0000",
    "lscpu.stepping"=> "5",
    "virt.host_type"=> "virtualbox",
    "lscpu.l2d_cache"=> "6144K",
    "uname.machine"=> "x86_64",
    "lscpu.thread(s)_per_core"=> "1",
    "cpu.cpu_socket(s)"=> "1",
    "net.interface.eth1.hwaddr"=> rand_mac,
    "lscpu.cpu(s)"=> "1",
    "uname.version"=> "#1 SMP Fri Oct 22 15=>36=>08 UTC 2010",
    "distribution.version"=> "14",
    "lscpu.architecture"=> "x86_64",
    "dmi.system.manufacturer"=> "innotek GmbH",
    "network.ipaddr"=> "#{ip}.4",
    "system.entitlements_valid"=> "true",
    "dmi.system.uuid"=> rand_uuid,
    "uname.release"=> "2.6.35.6-48.fc14.x86_64",
    "dmi.system.serial_number"=> "0",
    "dmi.bios.version"=> "VirtualBox",
    "cpu.core(s)_per_socket"=> "1",
    "lscpu.core(s)_per_socket"=> "1",
    "net.interface.lo.broadcast"=> "0.0.0.0",
    "memory.swaptotal"=> "2031612",
    "net.interface.lo.netmask"=> "255.0.0.0",
    "lscpu.model"=> "37",
    "lscpu.cpu_mhz"=> "2825.811",
    "net.interface.eth1.netmask"=> "255.255.255.0",
    "lscpu.numa_node(s)"=> "1",
    "net.interface.lo.hwaddr"=> "00=>00=>00=>00=>00=>00",
    "uname.nodename"=> "killing-time.appliedlogic.ca",
    "dmi.bios.vendor"=> "innotek GmbH",
    "network.hostname"=> "killing-time.appliedlogic.ca",
    "net.interface.eth1.broadcast"=> "#{ip}.255",
    "memory.memtotal"=> "1023052",
    "dmi.system.wake-up_type"=> "Power Switch",
    "cpu.cpu(s)"=> "1",
    "virt.is_guest"=> "true",
    "dmi.system.sku_number"=> "Not Specified",
    "net.interface.lo.ipaddr"=> "127.0.0.1",
    "distribution.id"=> "Laughlin",
    "lscpu.cpu_socket(s)"=> "1",
    "dmi.system.version"=> "1.2",
    "dmi.bios.rom_size"=> "128 KB",
    "lscpu.vendor_id"=> "GenuineIntel",
    "net.interface.eth1.ipaddr"=> "#{ip}.8",
    "lscpu.cpu_family"=> "6",
    "dmi.bios.relase_date"=> "12/01/2006",
    "lscpu.numa_node0_cpu(s)"=> "0"
}



10.times do |i|
   ip = (0..2).collect{rand(255).to_s}.join(".")
   facts["net.interface.eth1.hwaddr"] = rand_mac
   facts["dmi.system.uuid"] = rand_uuid
   facts["network.ipaddr"] = "#{ip}.4"
   facts["net.interface.eth1.broadcast"] = "#{ip}.255"
   facts["net.interface.eth1.ipaddr"] = "#{ip}.8"
   facts["network.hostname"]= "killing-time#{i}.appliedlogic." + ["org","edu","com","in","ca"].choice
   
   sys_name = sprintf("%02d-#{sys}", i)
   System.create! :name=>sys_name,:environment=>e, :cp_type=>"system", :facts =>facts
end
