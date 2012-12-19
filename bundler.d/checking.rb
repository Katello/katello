group :checking do
  unless defined? JRUBY_VERSION
    # TODO - lock until we get this working on rhel6
    gem 'therubyracer', "= 0.11.0beta8", :require => "v8"
    gem 'ref'
#    gem 'libv8'
  end
  gem 'jshintrb', '0.2.1'
    gem 'execjs'
    gem 'multi_json', '>= 1.3'
end
