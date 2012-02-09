require 'ostruct'

# OpenStruct has no to_hash method and cannot be easily converted to JSON
# using to_json Rails method. This adds the missing piece.
class OpenStruct

  def to_hash
    # we are NOT making copy - do not modify it
    @table
  end

end

