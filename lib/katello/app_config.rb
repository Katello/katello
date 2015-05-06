module Katello
  class AppConfigDeprecate
    def method_missing(method, *args, &block)
      warn "AppConfig is deprecated use Katello.config, called from: #{caller.first}"
      Katello.config.__send__ method, *args, &block
    end
  end
end

AppConfig = Katello::AppConfigDeprecate.new
