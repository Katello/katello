group :checking do
  unless defined? JRUBY_VERSION
    gem 'jshintrb', :git => "git://github.com/Katello/jshintrb.git"
      gem 'execjs'
      gem 'multi_json', '>= 1.3'
  end
end
