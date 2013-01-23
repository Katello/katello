def rails32?
  version = `uname -a` rescue ""
  begin
    require 'rails'
  rescue LoadError
    return (version =~ /fc18/)
  end
  return (version =~ /fc18/) unless defined?(Rails)
  rails_version = Rails::VERSION::STRING
  rails_version =~ %r{^3.2}
end

# Stuff for view/display/frontend
group :assets do
  gem 'haml', '>= 3.1.2'
  gem 'haml-rails', "= 0.3.4"
  begin 
    require 'compass'
    if Gem.loaded_specs["compass"].version < Gem::Version.new("0.12.0")
      gem 'compass', '~> 0.11.5'
    else
      gem 'compass', '~> 0.12.0'
      gem 'compass-rails', '~> 1.0.3'
      if rails32?
        gem 'sass-rails'
        gem 'actionpack'
      end
    end
  rescue LoadError
    gem 'compass', '~> 0.12.0'
    gem 'compass-rails', '~> 1.0.3'
    if rails32?
      gem 'sass-rails'
      gem 'actionpack'
    end
  end
  gem 'compass-960-plugin', '>= 0.10.4', :require => 'ninesixty'
  gem 'simple-navigation', '>= 3.3.4'
end
