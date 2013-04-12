group :checking do
  unless defined? JRUBY_VERSION
    gem 'jshintrb', '0.2.1'
      gem 'execjs'
      gem 'multi_json', '>= 1.3'
  end
end
