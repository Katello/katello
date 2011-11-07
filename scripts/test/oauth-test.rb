#!/usr/bin/ruby

require 'rubygems'
require 'oauth'

consumer_key = "katello"
consumer_secret = "PUTYSOURSECRETHERE"

# To test candlepin you can call the following URL
# https://localhost:8443/candlepin/products/

consumer = OAuth::Consumer.new(
                           consumer_key,
                           consumer_secret,
                           #:site => "https://localhost:8443",
                           :site => "https://localhost",
                           :request_token_path => "",
                           :authorize_path => "",
                           :access_token_path => "",
                           :http_method => :post
                          )

access_token = OAuth::AccessToken.new consumer
response = access_token.get("/pulp/api/users/", { 'pulp-user'=>'admin' })
body = response.body
puts body
