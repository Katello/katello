#!/usr/bin/ruby
#
# Script to create a valid candlepin export.zip which can then be imported
# for an owner. Creates everything necessary, starting with a fresh owner,
# admin user, candlepin consumer, products, subs, pools, and entitlements.
#
# None of the above will be cleaned up.

#require  "./client/ruby/candlepin_api"
require  "./candlepin/candlepin/client/ruby/candlepin_api"
require 'pp'

ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "admin"
HOST = "somecandlepinhost.example.com"
PORT = 8443

def random_string prefix=nil
  prefix ||= "rand"
  return "#{prefix}-#{rand(10000000)}"
end

cp = Candlepin.new(ADMIN_USERNAME, ADMIN_PASSWORD, nil, nil, HOST, PORT)

owner = cp.get_owner('admin')

# Create a "Candlepin" consumer representing the downstream Candlepin server:
consumer = cp.register(random_string('katello'), "candlepin", nil, {}, 'admin', 'admin')
consumer_cp = Candlepin.new(nil, nil, consumer['idCert']['cert'], consumer['idCert']['key'],
  HOST, PORT)
puts "Created upstream Candlepin consumer: #{consumer['uuid']}"

# Bind to pools for each of the products in the demo:
product_ids = [
  'rhui',
  'rhel6-server',
]

product_ids.each do |product_id|
  quantity = 100
  # We know there'll only be one pool for each product:
  puts "Exporting #{quantity} entitlements for: #{product_id}"
  pool = cp.list_pools(:owner => owner['id'], :product => product_id)[0]
  consumer_cp.consume_pool(pool['id'], {:quantity => 100})
end

# Make a temporary directory where we can safely extract our archive:
tmp_dir = File.join(Dir.tmpdir, random_string('candlepin-export'))
export_dir = File.join(tmp_dir, "export")
Dir.mkdir(tmp_dir)

export_filename = consumer_cp.export_consumer(tmp_dir)
puts "Your export is ready: #{export_filename}"
