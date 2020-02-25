module Katello
  class PreventJsonParsing
    def initialize(app, exclude)
      @app = app
      @exclude = exclude
    end

    def call(env)
      if @exclude&.call(env)
        env['CONTENT_TYPE'] = 'text/plain'
      end
      @app.call(env)
    end
  end
end
