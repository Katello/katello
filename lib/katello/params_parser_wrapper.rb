module Katello
  class ParamsParserWrapper < ActionDispatch::ParamsParser
    def initialize(app, excludes)
      @exclude = excludes
      super(app)
    end

    def call(env)
      if @exclude && @exclude.call(env)
        @app.call(env)
      else
        super(env)
      end
    end
  end
end
