group :checking do
  unless defined? JRUBY_VERSION
    gem 'therubyracer', ">= 0.11.0beta"
      gem 'ref'
  end
  gem 'jshintrb', '0.2.1'
    gem 'execjs'
    gem 'multi_json', '>= 1.3'
end
