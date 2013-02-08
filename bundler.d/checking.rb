group :checking do
  unless defined? JRUBY_VERSION
    gem 'therubyracer', "~> 0.11.0", :require => "v8"
      gem 'ref'
    gem 'jshintrb', '0.2.1'
      gem 'execjs'
      gem 'multi_json', '>= 1.3'
  end
end
