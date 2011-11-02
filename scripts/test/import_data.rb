#!/usr/bin/ruby

require 'rubygems'
require 'rest_client'
require 'date'
require 'json'
require 'pp'

PROVIDER_JSON = "provider.json"
PRODUCT_JSON = "products.json"
ORGANIZATIONS_JSON = "organizations.json"

providers_data = JSON(File.read(PROVIDER_JSON))
products_data = JSON(File.read(PRODUCT_JSON))
owners_data = JSON(File.read(ORGANIZATIONS_JSON))['owners']

katello = RestClient::Resource.new "http://localhost:3000/api", :user => 'admin', :password => 'admin'
cp = RestClient::Resource.new "https://localhost:8443/candlepin", :user => 'admin', :password => 'admin'

p "Creating provider..."
provider_ret = JSON.parse(katello['/providers'].post providers_data.to_json, :content_type => :json, :accept => :json)

# create some owners and users
owners_data.each do |new_owner|
  owner_name = new_owner['name']
  users = new_owner['users']

  puts "owner: #{owner_name}"

  # Kind of a hack to allow users under
  # the default 'admin' owner
  if owner_name == 'admin'
    owner = { 'name' => 'admin' }
  else
    owner = JSON.parse(katello["/organizations"].post("name=#{owner_name}&description=#{owner_name}"))
  end

  users.each do |user|
    puts "   user: #{user['username']}"
    cp["/owners/#{owner['name'].tr(' ', '_')}/users"].post({'username' => user['username'], 'password' => user['password']}.to_json, :content_type => :json, :accept => :json)
  end
end

owners = JSON.parse(cp["/owners"].get :accept => :json)
owner_key = owners[0]['key']

CERT_DIR='generated_certs'
if not File.directory? CERT_DIR
	Dir.mkdir(CERT_DIR)
end

puts "import product data..."
katello["/providers/#{provider_ret['_id']}/import_products"].post products_data.to_json, :content_type => :json, :accept => :json
product_ret = JSON.parse(cp["/products"].get :accept => :json)

owner_key = 'snowwhite'
contract_number = 0
product_ret.each do |product|
          if product['id'].to_i.to_s != id:
              subscription = JSON.parse(cp["/owners/#{owner_key}/subscriptions"].post ({
                                          'startDate' => Date.today,
                                          'endDate'   => Date.today + 365,
                                          'quantity'  =>  5,
                                          'accountNumber' => '12331131231',
                                          'product' => { 'id' => product['id'] },
                                          'providedProducts' => [],
                                          'contractNumber' => contract_number
                                        }.to_json, :content_type => :json, :accept => :json))
              contract_number += 1                                                    
              subscription = JSON.parse(cp["/owners/#{owner_key}/subscriptions"].post({
                                          'startDate' => Date.today,
                                          'endDate'   => Date.today + 365,
                                          'quantity'  =>  10,
                                          'accountNumber' => '12331131231',
                                          'product' => { 'id' => product['id'] },
                                          'providedProducts' => [],
                                          'contractNumber' => contract_number
                                        }.to_json, :content_type => :json, :accept => :json))
                                                    
              # go ahead and create a token for each subscription, the token itself is just a random int
              cp["/subscriptiontokens"].post({'token' => rand(10000000000),'subscription' => {'id' => subscription['id']}}.to_json, :content_type => :json, :accept => :json)
              contract_number += 1

              # create a future dated model
              subscription = JSON.parse(cp["/owners/#{owner_key}/subscriptions"].post({
                                          'startDate' => Date.today + 355,
                                          'endDate'   => Date.today + 720,
                                          'quantity'  =>  15,
                                          'accountNumber' => '12331131231',
                                          'product' => { 'id' => product['id'] },
                                          'providedProducts' => [],
                                          'contractNumber' => contract_number
                                        }.to_json, :content_type => :json, :accept => :json))
              contract_number += 1
          end

          if id.to_i.to_s == id:
              product_cert = JSON.parse(cp["/products/#{product_ret['id']}/certificate"].get :accept => :json)
              cert_file = File.new(CERT_DIR + '/' + product['id'] + '.pem', 'w+')
              cert_file.puts(product_cert['cert'])
          end
end

# tickle the subscriptions to get an entitlement pool
cp["/owners/#{owner_key}/subscriptions"].put(nil, :content_type => :json, :accept => :json)
