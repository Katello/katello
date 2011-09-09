module HttpErrors

  class WrappedError < StandardError
    attr_reader :original

    def initialize(msg, original=$!)
      super(msg)
      @original = original
    end
  end

  # application general errors
  class AppError < WrappedError; end
  class ApiError < AppError; end

  # specific errors
  class NotFound < WrappedError; end
  class BadRequest < WrappedError; end
  class Conflict < WrappedError; end

end
